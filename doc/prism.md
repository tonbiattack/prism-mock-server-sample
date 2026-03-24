# Prism とは

[Stoplight Prism](https://stoplight.io/open-source/prism) は、OpenAPI 定義ファイル（`.yaml` / `.json`）を読み込んで、実際のバックエンドなしに HTTP モックサーバーを立てられる OSS ツールです。

## できること

- OpenAPI の `example` / `examples` / `schema` をもとにレスポンスを自動生成
- リクエストのバリデーション（スキーマに合わない入力を 400/422 で弾く）
- `Prefer: code=XXX` ヘッダーで任意のステータスコードを強制返却
- `--dynamic` モードでスキーマからランダム値を生成

## 主な用途

- フロントエンドの先行開発（バックエンド未実装でも動かせる）
- レスポンス形式の認識合わせ
- エラーハンドリングの実装確認
- OpenAPI 定義の妥当性チェック

---

## インストール

このプロジェクトでは `devDependencies` に含まれているので、`npm install` だけで使えます。

```bash
npm install
```

グローバルにインストールして使う場合：

```bash
npm install -g @stoplight/prism-cli
```

---

## 起動オプション

### 基本起動（static モード）

```bash
npm run mock
# 内部では: prism mock openapi.yaml
```

OpenAPI の `example` フィールドに定義した値をそのまま返します。レスポンスは毎回同じです。

### 詳細ログ表示

```bash
npm run mock:verbose
# 内部では: prism mock openapi.yaml --verbose
```

リクエスト/レスポンスのネゴシエーション過程をすべてログ出力します。

### dynamic モード

```bash
npm run mock:dynamic
# 内部では: prism mock openapi.yaml --dynamic
```

`example` を無視して、`schema` の型情報から faker.js でランダム値を生成します。毎回異なる値が返るため、UI のロバスト性確認に使えます。

### ポート変更

```bash
npx prism mock openapi.yaml --port 8080
```

デフォルトは `4010` 番ポート。

---

## Prefer ヘッダーによるレスポンス制御

`Prefer: code=XXX` ヘッダーを付けると、openapi.yaml に定義されたどのステータスコードでも強制的に返せます。

```bash
# 500 を返させる例
curl http://localhost:4010/todos/1 \
  -H "Prefer: code=500"

# 404 を返させる例
curl http://localhost:4010/todos/1 \
  -H "Prefer: code=404"
```

**前提：** openapi.yaml の対象エンドポイントにそのステータスコードが定義されている必要があります。定義にないコードを指定すると無視されます。

---

## レスポンス生成の優先順位（static モード）

Prism は以下の順でレスポンス値を探します。

1. エンドポイントの `example` フィールド
2. `examples` フィールドの最初のエントリ
3. スキーマの各プロパティの `example` フィールド
4. どれもなければ空レスポンスまたはエラー

→ openapi.yaml に `example` をしっかり書くほど、意図したモックレスポンスが返ります。

---

## バージョン

このプロジェクトで使用しているバージョン：`@stoplight/prism-cli` v5.x

公式ドキュメント：https://docs.stoplight.io/docs/prism
