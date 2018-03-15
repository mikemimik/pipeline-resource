FROM node:carbon-alpine

RUN apk --update add curl gawk

RUN curl -Lo \
    fly https://github.com/concourse/concourse/releases/download/v3.9.1/fly_linux_amd64 \
    && chmod +x fly \
    && mv fly /usr/local/bin/

COPY package.json /opt/resource/package.json
COPY package-lock.json /opt/resource/package-lock.json
WORKDIR /opt/resource
RUN npm install

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*