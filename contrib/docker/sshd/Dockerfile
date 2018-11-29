FROM alpine:latest
MAINTAINER CSIRO

RUN apk add --update openssh-server openssh-sftp-server
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?UsePAM\s+.*/#UsePAM no/g' /etc/ssh/sshd_config
RUN echo "SSHD_DISABLE_KEYGEN=true" >> /etc/conf.d/sshd
RUN ssh-keygen -A
RUN ls -lah
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

