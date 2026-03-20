# Prism モックサーバー サンプル

[Stoplight Prism](https://stoplight.io/open-source/prism) を使って OpenAPI 定義からモックサーバーを立てるサンプルプロジェクトです。

## 構成

```
.
├── openapi.yaml          # OpenAPI 3.0 定義（Todo API）
├── package.json
├── requests/
│   └── todo.http         # VSCode REST Client 用リクエスト集
└── scripts/
    └── test-api.sh       # curl によるAPIテストスクリプト
```

## セットアップ

```bash
npm install
```

## モックサーバー起動

```bash
# 通常起動（exampleの値を返す）
npm run mock

# ログ詳細表示
npm run mock:verbose

# ダイナミックモード（スキーマからランダム値を生成）
npm run mock:dynamic
```

起動すると `http://localhost:4010` でモックサーバーが立ち上がります。

## API エンドポイント

| メソッド | パス         | 説明               |
|----------|------------|------------------|
| GET      | /todos      | Todo一覧取得         |
| POST     | /todos      | Todo作成           |
| GET      | /todos/{id} | Todo詳細取得         |
| PATCH    | /todos/{id} | Todoステータス更新      |
| DELETE   | /todos/{id} | Todo削除           |

## APIのたたき方

### VSCode REST Client（推奨）

拡張機能 [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) をインストールして、`requests/todo.http` を開いて `Send Request` をクリックするだけです。

### curl スクリプト

```bash
bash scripts/test-api.sh
```

全エンドポイントを順番に呼び出してレスポンスを確認できます。

### curl 個別実行例

```bash
# Todo一覧取得
curl http://localhost:4010/todos

# Todo詳細取得
curl http://localhost:4010/todos/1

# Todo作成
curl -X POST http://localhost:4010/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "新しいタスク"}'

# ステータス更新
curl -X PATCH http://localhost:4010/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'

# 削除
curl -X DELETE http://localhost:4010/todos/1
```

## Prism の挙動について

- `example` フィールドが OpenAPI に定義されていれば、その値がレスポンスとして返ります
- `--dynamic` フラグを付けると、スキーマをもとにランダム値を生成します
- リクエストのバリデーションも行われ、スキーマに合わない場合は 400/422 が返ります
