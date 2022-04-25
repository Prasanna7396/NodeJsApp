FROM openjdk:11

LABEL maintainer="prasanna.jadhav104@gmail.com"

RUN mkdir -p /opt/NodeJsApp

RUN apt update && \
    apt install curl && \
    apt-get install npm

WORKDIR /opt/NodeJsApp

COPY . /opt/NodeJsApp

CMD ["node","index.js"]
