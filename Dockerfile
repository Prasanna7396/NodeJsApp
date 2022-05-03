FROM ubuntu

LABEL maintainer="prasanna.jadhav104@gmail.com"

RUN apt update && \
    apt install npm -y && mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY index.js package.json package-lock.json .

RUN npm install

EXPOSE 8050

CMD ["node","index.js"]
