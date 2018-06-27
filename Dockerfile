FROM node:carbon-alpine

ENV FLY_VERSIONS="3.9.1 3.9.2 3.10.0 3.11.0 3.12.0 3.13.0 3.14.0 3.14.1"
ENV DEFAULT_FLY_VERSION="3.14.1"

RUN apk --update add curl gawk

RUN for FLY_VERSION in ${FLY_VERSIONS}; do \
    curl -Lo \
    fly-${FLY_VERSION} https://github.com/concourse/concourse/releases/download/v${FLY_VERSION}/fly_linux_amd64 \
    && chmod +x fly \
    && mv fly /usr/local/bin/; \
    done
RUN cp /usr/local/bin/fly-${DEFAULT_FLY_VERSION} /usr/local/bin/fly

COPY package.json /opt/resource/package.json
COPY package-lock.json /opt/resource/package-lock.json
WORKDIR /opt/resource
RUN npm install

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*