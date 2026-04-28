# -------------------------
# Stage 1
# -------------------------
FROM node:22 AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# -------------------------
# Stage 2
# -------------------------
FROM node:22.22-alpine3.23

WORKDIR /app

COPY package*.json ./
RUN npm install 

COPY --from=build /app .

ENV NODE_ENV=staging

EXPOSE 3000

CMD ["node", "server.js"]