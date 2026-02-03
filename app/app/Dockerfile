FROM node:18-alpine

RUN apk add --no-cache curl

WORKDIR /app
COPY package.json .
RUN npm install

COPY server.js .
EXPOSE 3000

HEALTHCHECK \
  --start-period=20s \
  --interval=30s \
  --timeout=5s \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["node", "server.js"]