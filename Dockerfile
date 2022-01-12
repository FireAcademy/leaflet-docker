FROM ubuntu:latest

ENV CHIA_ROOT=/root/.chia/mainnet
ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV TZ="UTC"
ENV upnp="false"
ENV log_to_file="true"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y bc curl lsb-release python3 tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3.8-venv python3.8-distutils python-is-python3 vim tzdata && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh && \
    chmod +x nodesource_setup.sh && \
    ./nodesource_setup.sh && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

RUN git config --global core.autocrlf input && \
    git clone --branch master https://github.com/FireAcademy/leaflet && \
    cd leaflet && \
    npm install 

ARG BRANCH=latest

RUN echo "cloning ${BRANCH}" && \
    git clone --branch ${BRANCH} https://github.com/Chia-Network/chia-blockchain.git && \
    cd chia-blockchain && \
    git submodule update --init mozilla-ca && \
    /usr/bin/sh ./install.sh

ENV PATH=/chia-blockchain/venv/bin:$PATH
WORKDIR /chia-blockchain

RUN apt-get install -y zip unzip
COPY docker-start.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-start.sh"]
