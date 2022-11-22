FROM node:lts-alpine

RUN npm install -g http-server

WORKDIR /app

COPY on-this-day/package*.json ./

RUN npm install

COPY on-this-day/ .

RUN npm run build

EXPOSE 8080

CMD [ "http-server", "dist" ]