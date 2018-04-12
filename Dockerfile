# docker build . -t ckan && docker run -d -p 80:5000 --link db:db --link redis:redis --link solr:solr ckan

FROM debian:jessie
MAINTAINER Open Knowledge

ENV CKAN_HOME /usr/lib/ckan/default
ENV CKAN_CONFIG /etc/ckan/default
ENV CKAN_STORAGE_PATH /var/lib/ckan
ENV CKAN_SITE_URL http://localhost:5000

# Install required packages
RUN apt-get -q -y update && apt-get -q -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
		python-dev \
        python-pip \
        python-virtualenv \
        libpq-dev \
        git-core \
	libffi-dev \
	&& apt-get -q clean
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

# SetUp Requirements
ADD ./requirements.txt $CKAN_HOME/src/ckan/requirements.txt
RUN ckan-pip install --upgrade -r $CKAN_HOME/src/ckan/requirements.txt

# TMP-BUGFIX https://github.com/ckan/ckan/issues/3388
ADD ./dev-requirements.txt $CKAN_HOME/src/ckan/dev-requirements.txt
RUN ckan-pip install --upgrade -r $CKAN_HOME/src/ckan/dev-requirements.txt

# TMP-BUGFIX https://github.com/ckan/ckan/issues/3594
RUN ckan-pip install --upgrade urllib3

# SetUp CKAN
ADD . $CKAN_HOME/src/ckan/
RUN ckan-pip install -e $CKAN_HOME/src/ckan/
RUN ln -s $CKAN_HOME/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini
#COPY ./contrib/docker/config/ckan.ini $CKAN_CONFIG/ckan.ini

# Setup Remote Debugging for Pycharm 
RUN . /usr/lib/ckan/default/bin/activate && pip install pydevd 
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/NaturalHistoryMuseum/ckanext-dev.git#egg=ckanext-dev

# Setup LDAP ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/NaturalHistoryMuseum/ckanext-ldap.git#egg=ckanext-ldap
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-ldap/requirements.txt

# setup ckanext-spatial
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/okfn/ckanext-spatial.git#egg=ckanext-spatial
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-spatial/pip-requirements.txt

RUN . /usr/lib/ckan/default/bin/activate && pip install ckanext-geoview


# Setup ckanext-org ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e "git+https://github.com/datagovuk/ckanext-hierarchy.git#egg=ckanext-hierarchy"

# Setup DAMC digital assets ckan Plugin
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-digitalassetfields.git#egg=ckanext-digitalassetfields
RUN . /usr/lib/ckan/default/bin/activate && pip install -r /usr/lib/ckan/default/src/ckanext-digitalassetfields/requirements.txt

# Setup DAMC themes
RUN . /usr/lib/ckan/default/bin/activate && pip install -e git+https://github.com/CSIRO-enviro-informatics/ckanext-csiro_hub_theme.git#egg=ckanext-csiro_hub_theme

# SetUp EntryPoint
COPY ./contrib/docker/wait-for-it.sh /
RUN chmod +x /wait-for-it.sh
RUN mkdir /entrypoint
COPY ./contrib/docker/ckan-entrypoint.sh /entrypoint/
RUN chmod +x /entrypoint/ckan-entrypoint.sh
RUN ln -s /entrypoint/ckan-entrypoint.sh  /
ENTRYPOINT ["/ckan-entrypoint.sh"]


# Volumes
VOLUME ["/entrypoint"]
VOLUME ["/etc/ckan/default"]
VOLUME ["/usr/lib/ckan"]
VOLUME ["/var/lib/ckan"]
EXPOSE 5000
CMD ["ckan-paster","serve","/etc/ckan/default/ckan.ini"]
