FROM node:16.8.0-alpine3.12

WORKDIR /app

COPY package.json .
RUN npm install --only=production

COPY . .

EXPOSE 4433

ENTRYPOINT [ "node", "index.js" ]