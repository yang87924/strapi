FROM node:18-alpine3.18

# 切換到 root 使用者
USER root

# 更新並安裝必要套件
RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips \
    vips-dev \
    git \
    python3 \
    make

# 設定環境變數
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app

# 確保 node-gyp 正確安裝
RUN npm install -g node-gyp

# 複製 package.json 和 package-lock.json
COPY package.json package-lock.json ./

# 設定權限，避免權限問題
RUN chown -R node:node /opt/app

# 安裝 npm 依賴，確保 sharp 正確安裝
USER node
RUN npm install --platform=linuxmusl --arch=x64 sharp
RUN npm ci --ignore-scripts

# 重新編譯 sharp，避免缺失依賴問題
RUN npm rebuild sharp

# 設定 PATH
ENV PATH=/opt/app/node_modules/.bin:$PATH

# 複製專案文件
COPY --chown=node:node . .

# 確保 Strapi 能夠正確建置
RUN npm run build

# 開放 Strapi 端口
EXPOSE 1337

# 啟動 Strapi
CMD ["npm", "run", "develop"]
