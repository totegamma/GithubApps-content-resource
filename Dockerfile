FROM ubuntu:bionic

RUN apt update \
 && apt upgrade -y \
 && apt install -y --no-install-recommends \
    ca-certificates curl wget jq

RUN wget https://github.com/mike-engel/jwt-cli/releases/download/5.0.3/jwt-linux.tar.gz \
 && tar -zxvf jwt-linux.tar.gz \
 && mv jwt /usr/local/bin

ADD src/ /opt/resource

