# Prism モックサーバー サンプル

## はじめに

[Stoplight Prism](https://stoplight.io/open-source/prism) を使って OpenAPI 定義からモックサーバーを立てるサンプルプロジェクトです。OpenAPI ファイルを用意するだけでバックエンド実装なしにモックサーバーを起動でき、フロントエンド開発や API 設計の検証に使えます。

## Prism とは

Prism は OpenAPI（v2 / v3）定義ファイルを読み込み、実際のバックエンド実装なしに HTTP モックサーバーを立ち上げられる OSS ツールです。

```bash
# これだけでモックサーバーが起動する
prism mock openapi.yaml
```

## なぜ Prism を使うのか

### Swagger 先行開発の落とし穴

フロントエンドとバックエンドを分離して開発する場合、よくある進め方は次のとおりです。

1. Swagger（OpenAPI）でエンドポイント・リクエスト・レスポンスを決める
2. フロントとバックが並行して実装する
3. 最後に結合してテストする

一見効率的ですが、最初に合意した仕様を後から変えにくいという問題が起きやすい構造です。

実装を進めると設計の問題に気づきますが、そのとき双方がすでに実装済みであれば変更コストが高く、「まあこのままでいいか」という判断を繰り返すことになります。

### Prism が解決すること

Prism を使うと「まずモックで動かして検証する」サイクルを早い段階で回せます。

```
OpenAPI を書く → Prism で即起動 → フロントから叩いて検証 → 設計を修正
```

実装が始まる前にスキーマの問題を発見できるため、後からの破壊的変更を減らせます。

## ユースケース

### フロントエンド先行開発

バックエンドの実装を待たずにフロントの開発・テストができます。OpenAPI に `example` を定義しておけば、Prism が即座にそのレスポンスを返します。

```yaml
# openapi.yaml に example を書いておくだけ
responses:
  '200':
    content:
      application/json:
        example:
          id: 1
          title: "買い物をする"
```

### 設計の早期検証

結合テストを待たず、モックサーバーを通じてフロントとバックが実際のデータのやりとりを早めに体験できます。「このフィールド名はわかりにくい」「ここはネストにした方がいい」という気づきを、まだ変更しやすい段階で得られます。

### エラーハンドリングの確認

`Prefer: code=XXX` ヘッダーを使うと、任意のエラーレスポンスを強制的に返せます。バックエンドがエラーを実装していなくても、フロントのエラー処理を先に作れます。

```bash
# 500 エラーのレスポンスを返させる
curl http://localhost:4010/todos/1 \
  -H "Prefer: code=500"

# 401 認証エラーを返させる
curl http://localhost:4010/todos/1 \
  -H "Prefer: code=401"
```

### レスポンス形式の認識合わせ

フロントとバックで「`null` を返すのか `""` を返すのか」「配列で返すのかオブジェクトで返すのか」といった齟齬は、実装してから発覚することが多いです。Prism を使えば openapi.yaml の `example` を実際に返すため、認識のズレをコード実装前に検出できます。

### OpenAPI 定義の妥当性チェック

Prism はリクエストのバリデーションも行います。スキーマに合わないリクエストを送ると 400/422 が返るため、OpenAPI 定義自体の矛盾や抜けを起動・動作確認を通じて発見できます。

## 構成

```
.
├── openapi.yaml          # OpenAPI 3.0 定義（Todo API）
├── package.json
├── Dockerfile            # Docker イメージ定義
├── docker-compose.yml    # Docker Compose 設定
├── requests/
│   └── todo.http         # VSCode REST Client 用リクエスト集
├── scripts/
│   └── test-api.sh       # curl によるAPIテストスクリプト
└── docs/
    ├── prism.md                       # Prism の詳細解説
    ├── npm-files.md                   # package.json / package-lock.json の解説
    ├── package-manager-comparison.md  # 言語別パッケージ管理の比較
    └── backward-compatibility.md      # バージョンアップと後方互換性の比較
```

## セットアップ

```bash
npm install
```

## Docker で起動する（社内共有・チーム利用向け）

Node.js のインストール不要で、Docker があれば誰でも同じ環境でモックサーバーを起動できます。

### 起動

```bash
docker compose up --build
```

バックグラウンドで起動する場合:

```bash
docker compose up -d --build
```

起動後は `http://localhost:4010` でアクセスできます。停止は `docker compose down` です。

### ポートの変更

ホスト側のポートだけ変える場合は `docker-compose.yml` の `ports` を編集します。

```yaml
# docker-compose.yml
ports:
  - "8080:4010"  # 左がホスト側、右がコンテナ内ポート
```

アクセスURLが `http://localhost:8080` になります。

変更後は以下のコマンドでコンテナを再起動してください。

```bash
# down: 起動中のコンテナを停止・削除
# up --build: イメージを再ビルドしてコンテナを起動
docker compose down && docker compose up --build
```

コンテナ内のポートも合わせて変えたい場合は `Dockerfile` の `CMD` も変更します。

```yaml
# docker-compose.yml
ports:
  - "8080:8080"
```

```dockerfile
# Dockerfile
CMD ["npx", "prism", "mock", "--host", "0.0.0.0", "--port", "8080", "openapi.yaml"]
```

変更後は以下のコマンドでコンテナを再起動してください。

```bash
# down: 起動中のコンテナを停止・削除
# up --build: イメージを再ビルドしてコンテナを起動
docker compose down && docker compose up --build
```

### ベースURLの変更

`openapi.yaml` の `servers.url` を変更します。

```yaml
# openapi.yaml
servers:
  - url: http://localhost:8080  # ポートに合わせて変更
```

> **注意:** この値は Prism のバリデーション参照用であり、実際のアクセスURLには影響しません。パスのプレフィックスを変えたい場合（例: `/api/v1/todos`）は `paths` の定義自体を変更してください。

```yaml
# openapi.yaml
paths:
  /api/v1/todos:   # /todos → /api/v1/todos に変更
```

### openapi.yaml の変更をコンテナに反映する

`openapi.yaml` はボリュームマウントされているため、ファイルを編集するだけでコンテナの再ビルドなしに変更が反映されます。

---

## モックサーバー起動

```bash
# 通常起動（example の値をそのまま返す）
npm run mock

# ログ詳細表示
npm run mock:verbose

# ダイナミックモード（スキーマからランダム値を生成）
npm run mock:dynamic
```

起動すると `http://localhost:4010` でモックサーバーが立ち上がります。

## API エンドポイント

| メソッド | パス | 説明 |
|---|---|---|
| GET | /todos | Todo一覧取得 |
| POST | /todos | Todo作成 |
| GET | /todos/{id} | Todo詳細取得 |
| PATCH | /todos/{id} | Todoステータス更新 |
| DELETE | /todos/{id} | Todo削除 |

## API のたたき方

### VSCode REST Client

拡張機能 [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) をインストールして `requests/todo.http` を開き、`Send Request` をクリックします。正常系・エラー系のリクエストがひと通り揃っています。

### curl スクリプト（全エンドポイント一括テスト）

```bash
bash scripts/test-api.sh
```

正常系・エラー系の全パターンを順番に呼び出してレスポンスを確認できます。

### curl 個別実行

```bash
# 正常系
curl http://localhost:4010/todos
curl http://localhost:4010/todos/1
curl -X POST http://localhost:4010/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "新しいタスク"}'

# エラー系（Prefer ヘッダーで強制指定）
curl http://localhost:4010/todos/1 -H "Prefer: code=404"
curl http://localhost:4010/todos/1 -H "Prefer: code=500"
```

## Prism の主な挙動

| 挙動 | 説明 |
|---|---|
| example 優先 | OpenAPI の `example` フィールドの値をそのまま返す |
| dynamic モード | `--dynamic` フラグで schema からランダム値を生成 |
| リクエストバリデーション | スキーマに合わないリクエストは 400/422 を返す |
| Prefer ヘッダー | `Prefer: code=XXX` で任意のステータスコードを強制返却 |

詳細は [docs/prism.md](docs/prism.md) を参照してください。
