############################
## Build the applications we need
############################
FROM ubuntu:latest
LABEL maintainer "aboron@gmail.com"

## Default ARGs and ENVs
#ARG branch=dev
#ARG operating_env=local
#ENV BUILD_ID=$BUILD_ID
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ=America/New_Tork

## Install preprerequisites
RUN apt-get update && apt-get install -y apt-utils
## Install prerequisites
RUN apt-get update && apt-get install -y wget apt-transport-https ca-certificates software-properties-common \
    curl gnupg2 unzip git unzip nginx php-fpm php-zip php-sqlite3 php-curl php-xml php-xmlrpc lsb-release

## Create storage and tools folders
RUN mkdir -p /opt/organizr-clean && \
    mkdir -p /opt/organizr && \
    mkdir -p /var/lib/nginx/body && \
    mkdir /config-clean && \
    mkdir /config && \
    mkdir /run/php && \
    chown -R www-data:www-data /config /config-clean /run/php /var/log /var/lib/nginx

RUN git clone https://github.com/causefx/Organizr.git /opt/organizr-clean && chown -R www-data:www-data /opt/organizr-clean

## Build and Install dav-api
COPY --chown=www-data:www-data nginx-default.conf php-fpm-pool.conf starter.sh /config-clean/
COPY starter.sh /opt/
RUN rm /etc/nginx/sites-enabled/default && \
    rm /etc/php/7.4/fpm/pool.d/www.conf && \
    ln -s /config/nginx-default.conf /etc/nginx/sites-enabled/default && \
    ln -s /config/php-fpm-pool.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN chmod 755 /opt/starter.sh

## Container application specs
VOLUME /opt/organizr
VOLUME /config

#HEALTHCHECK --interval=5s --timeout=5s \
#    CMD curl -f http://127.0.0.1:3000/ || exit 1

WORKDIR /opt/organizr
ENTRYPOINT ["/opt/starter.sh", ""]
