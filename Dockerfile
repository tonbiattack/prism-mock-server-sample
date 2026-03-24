FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY openapi.yaml ./

EXPOSE 4010

CMD ["npx", "prism", "mock", "--host", "0.0.0.0", "openapi.yaml"]
