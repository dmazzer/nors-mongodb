# This file is part of NORS project.
# http://github.com/dmazzer/nors

FROM ubuntu:14.04

MAINTAINER Daniel Mazzer "dmazzer@gmail.com"

EXPOSE 27017
EXPOSE 28017

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

RUN apt-get update \
        && apt-get install -y --no-install-recommends \
                numactl \
        && rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget

# Import MongoDB public GPG key AND create a MongoDB list file
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu $(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN apt-get update && \
	apt-get install -y \
	mongodb-org && \
	apt-get clean


# Create the MongoDB data directory
RUN mkdir -p /data/db /data/configdb \
        && chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb

# MongoDB related environment defines
ENV AUTH yes
ENV STORAGE_ENGINE wiredTiger
ENV JOURNALING yes

COPY run.sh /run.sh
COPY set_mongodb_password.sh /set_mongodb_password.sh
COPY docker-entrypoint.sh /entrypoint.sh

WORKDIR /data

#ENTRYPOINT ["/usr/local/bin/gosu" "mongodb" "/usr/bin/mongod"]

# Enable this entrypoint to create a random password for MongoDB database at
# first run
#ENTRYPOINT ["/run.sh"]
ENTRYPOINT ["/entrypoint.sh"]

#CMD ["/bin/bash"]
