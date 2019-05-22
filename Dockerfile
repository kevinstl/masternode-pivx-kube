# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.11

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]




# ...put your own build instructions here...
# From https://github.com/educatedwarrior/docker-pivx-masternode
ARG USER_ID
ARG GROUP_ID
ARG VERSION

ENV USER pivx
ENV COMPONENT ${USER}
ENV HOME /${USER}

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g ${GROUP_ID} ${USER} \
	&& useradd -u ${USER_ID} -g ${USER} -s /bin/bash -m -d ${HOME} ${USER}

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV VERSION ${VERSION:-3.2.2}
RUN wget -O /tmp/${COMPONENT}.tar.gz "https://github.com/PIVX-Project/PIVX/releases/download/v${VERSION}/pivx-${VERSION}-x86_64-linux-gnu.tar.gz" \
    && cd /tmp/ \
    && tar zxvf ${COMPONENT}.tar.gz \
    && mv /tmp/${COMPONENT}-* /opt/${COMPONENT}

EXPOSE 51470 51472

RUN set -x && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["${HOME}"]
WORKDIR ${HOME}
ADD ./bin /usr/local/bin


RUN echo $PATH
RUN ls -al /usr/local/bin


ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start-unprivileged.sh"]




# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
