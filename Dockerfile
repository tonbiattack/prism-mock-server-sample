FROM node:20-alpine

WORKDIR /app

COPY package.json ./
RUN npm install

COPY openapi.yaml ./

EXPOSE 4010

# 使いたいモードの行のコメントを外して docker compose up --build で再起動する

# 通常起動（example の値をそのまま返す）
CMD ["npx", "prism", "mock", "--host", "0.0.0.0", "openapi.yaml"]

# ログ詳細表示（リクエスト/レスポンスの詳細ログを表示）
# CMD ["npx", "prism", "mock", "--host", "0.0.0.0", "--verboseLevel", "debug", "openapi.yaml"]

# ダイナミックモード（schema からランダム値を生成）
# CMD ["npx", "prism", "mock", "--host", "0.0.0.0", "--dynamic", "openapi.yaml"]
