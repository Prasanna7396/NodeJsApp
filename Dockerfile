FROM node:14

LABEL maintainer="prasanna.jadhav104@gmail.com"

WORKDIR /usr/src/app

COPY . ,

RUN npm install

EXPOSE 8050

CMD ["node","index.js"]
