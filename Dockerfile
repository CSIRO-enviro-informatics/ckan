# See CKAN docs on installation from Docker Compose on usage
FROM debian:stretch
MAINTAINER Open Knowledge

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        python-dev \
        python-pip \
        python-virtualenv \
        python-wheel \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        build-essential \
        git-core \
	libffi-dev \
        vim \
        wget \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*
#-------------CKAN ext ldap dependencies----------------------------------------------------

RUN apt-get install -y python-dev libldap2-dev libsasl2-dev libssl-dev gcc
RUN pip install python-ldap


#CKAN spatial ext dependencies
RUN apt-get install -y libxml2-dev libxslt1-dev libgeos-c1

# SetUp Virtual Environment CKAN
RUN mkdir -p $CKAN_HOME $CKAN_CONFIG $CKAN_STORAGE_PATH
RUN virtualenv $CKAN_HOME
RUN ln -s $CKAN_HOME/bin/pip /usr/local/bin/ckan-pip
RUN ln -s $CKAN_HOME/bin/paster /usr/local/bin/ckan-paster
RUN /bin/bash -c "source $CKAN_HOME/bin/activate && $CKAN_HOME/bin/easy_install-2.7 -U \"pip==9.0.3\" \"setuptools==23.2.1\" && deactivate"
RUN rm -f $CKAN_HOME/lib/python2.7/site-packages/setuptools-23.2.1-py2.7.egg

# SetUp Requirements
RUN mkdir -p $CKAN_HOME/src/ckan
COPY ./requirements.txt $CKAN_HOME/src/ckan/requirements.txt
RUN ckan-pip install --upgrade -r $CKAN_HOME/src/ckan/requirements.txt

COPY ./dev-requirements.txt $CKAN_HOME/src/ckan/dev-requirements.txt
RUN ckan-pip install --upgrade -r $CKAN_HOME/src/ckan/dev-requirements.txt

#-------------uwsgi and paste-deploy for prod deployments----------------------------------------------------

RUN pip install uwsgi 
RUN pip install PasteDeploy 

# TMP-BUGFIX https://github.com/ckan/ckan/issues/3594
RUN ckan-pip install --upgrade urllib3

# SetUp CKAN
#ADD . $CKAN_HOME/src/ckan/
COPY ./ckan $CKAN_HOME/src/ckan/ckan
COPY ./ckanext $CKAN_HOME/src/ckan/ckanext
COPY ./contrib $CKAN_HOME/src/ckan/contrib
COPY ./setup.cfg ./setup.py ./requirement-setuptools.txt ./dev-requirements.txt $CKAN_HOME/src/ckan/
RUN ckan-pip install -e $CKAN_HOME/src/ckan/
RUN ln -s $CKAN_HOME/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini
#COPY ./contrib/docker/config/ckan.ini $CKAN_CONFIG/ckan.ini

# Setup Remote Debugging for Pycharm
RUN . /usr/lib/ckan/default/bin/activate && pip install pydevd
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/NaturalHistoryMuseum/ckanext-dev.git#egg=ckanext-dev

# Setup LDAP ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install "Jinja2==2.9.3"
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/NaturalHistoryMuseum/ckanext-ldap.git@v1.0.1#egg=ckanext-ldap
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-ldap/requirements.txt

# setup ckanext-spatial
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/okfn/ckanext-spatial.git#egg=ckanext-spatial
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-spatial/pip-requirements.txt

RUN . /usr/lib/ckan/default/bin/activate && pip install ckanext-geoview

#restricted plugin
#RUN . /usr/lib/ckan/default/bin/activate && pip install ckanext-restricted
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-restricted.git#egg=ckanext-restricted


#data requests
RUN . /usr/lib/ckan/default/bin/activate && pip install ckanext-datarequests

# Setup ckanext-org ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e "git+https://github.com/datagovuk/ckanext-hierarchy.git#egg=ckanext-hierarchy"

# Setup DAMC digital assets ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-digitalassetfields.git#egg=ckanext-digitalassetfields
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-digitalassetfields/requirements.txt

# Setup DAMC themes
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-csiro_hub_theme.git#egg=ckanext-csiro_hub_theme

# Setup User Extensions Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-user_ext.git#egg=ckanext-user_ext
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-user-ext/requirements.txt

# Setup User Opt In Plugin (dependent on the User Extensions Plugin)
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-user_opt_in.git#egg=ckanext-user_opt_in
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-user-opt-in/requirements.txt

# Setup EI's mod on dgu-organisation 
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-dgu_orgs.git#egg=ckanext-dgu_orgs
#RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-dgu_orgs/requirements.txt

RUN apt-get install -y postgresql-client

# Other ckan views
RUN . /usr/lib/ckan/default/bin/activate && pip install ckanext-pdfview

# SetUp EntryPoint
COPY ./contrib/docker/wait-for-it.sh /
RUN chmod +x /wait-for-it.sh
RUN mkdir /entrypoint
COPY ./contrib/docker/ckan-entrypoint.sh /entrypoint/
RUN chmod +x /entrypoint/ckan-entrypoint.sh
RUN ln -s /entrypoint/ckan-entrypoint.sh  /

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--", "/ckan-entrypoint.sh"]

# Volumes
VOLUME ["/entrypoint"]
VOLUME ["/etc/ckan/default"]
VOLUME ["/usr/lib/ckan"]
VOLUME ["/var/lib/ckan"]

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan

# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_SITE_URL

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    virtualenv $CKAN_VENV && \
    ln -s $CKAN_VENV/bin/pip /usr/local/bin/ckan-pip &&\
    ln -s $CKAN_VENV/bin/paster /usr/local/bin/ckan-paster

# Setup CKAN
ADD . $CKAN_VENV/src/ckan/
RUN ckan-pip install -U pip && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt && \
    ckan-pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt && \
    ckan-pip install -e $CKAN_VENV/src/ckan/ && \
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini && \
    cp -v $CKAN_VENV/src/ckan/contrib/docker/ckan-entrypoint.sh /ckan-entrypoint.sh && \
    chmod +x /ckan-entrypoint.sh && \
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

ENTRYPOINT ["/ckan-entrypoint.sh"]

USER ckan
EXPOSE 5000

CMD ["ckan-paster","serve","/etc/ckan/production.ini"]
