FORMAT: 1A

# MinecraftControllerAPI一覧

MinecraftControllerのAPI仕様です。

- ログインAPIとテスト用のAPI（バージョン取得API）を除く全てのAPIがAuthorizationヘッダにAPI Tokenを必要とします。
    - API TokenはログインAPIによって作成されます。
    - API Tokenには有効期限があり、サーバー側で設定された値を越えると使用できなくなり、再度ログインが必要になります。
    - API TokenがAuthorizationヘッダに指定されていない場合・不正な場合はBadRequestとして処理されます。

# Group ユーザー管理

## ログインAPI [POST /api/users/login]

- ログインを行い、API Tokenを発行します。

- Request (application/json)
    - Attributes
        - `id`: `user_name` (string, required) - ログインID
        - `password`: `password` (string, required) - パスワード

- Response 200 (application/json)
    - Attributes
        - `token`: `sometoken` (string, required) - API Token。ユーザー認証が必要なAPIのAuthorizationヘッダに使用する。

# Group Minecraftサーバー管理

## サーバー起動 [GET /api/ec2/start]

- Minecraftサーバーが設置されているEC2インスタンスを起動する。
    - サーバーの起動完了まで待機するため、レスポンスまで20〜30秒程度を要する。
    - EC2インスタンス起動をもって完了とするため、Minecraftサーバーが起動しているかは保証されない。

- Request
    - Headers

            authorization: some_api_token

- Response 200
    - Attributes
        - `ip`: `123.123.123.123` (string, required) - MinecraftサーバーのIPアドレス

# Group その他

## MinecraftControllerバージョン取得 [GET /api/version]

- MinecraftControllerのバージョンを取得する。このAPIはテスト用のため、そのうち削除される。

- Response 200
    - Attributes
        - `version`: `0.1.0` (string, required) - MinecraftControllerのバージョン
