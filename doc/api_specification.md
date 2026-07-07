# IF仕様書（API定義書）: 社員管理システム

対象システム: 社員管理システム（社内のメンバー情報を一元管理するバックエンドAPIシステム）
使用技術: Python (FastAPI)
ベースURL: `/api/v1`
本仕様は `doc/pbi.md` の PBI-1〜4 に対応する。エラーコード（`E0xx`）と多言語メッセージの詳細は Step3
（`doc/error_and_i18n_definition.md`、自習パート）で定義する。ここでは JSON 構造のみ確定する。

> PBI と同様に、受講者の受入条件に明記されていない箇所を補った部分には
> 【AI補完】を付けています。

---

## 共通仕様

- Content-Type: `application/json`（POST/PUT のリクエストボディに必須）
- 【AI補完】`Accept-Language` ヘッダー（任意、`ja` / `en` / `zh`。Step3の多言語メッセージ切り替え用。未指定時は `ja`）
- 社員情報オブジェクト（Employee）

  | フィールド | 型 | 説明 |
  |---|---|---|
  | employee_id | string | 社員番号（一意）|
  | name | string | 氏名 |
  | department | string | 所属部署 |
  | position | string | 役職 |

- エラーレスポンスの共通JSON構造

  ```json
  {
    "error": {
      "code": "E0xx",
      "message": "string",
      "details": [
        { "field": "string", "reason": "string" }
      ]
    }
  }
  ```
  - `details` はフィールド単位のバリデーションエラー時のみ付与（【AI補完】）。`code` の値は Step3 で確定する。

---

## 1. 社員情報一覧取得

`GET /employees`（PBI-1）

### リクエスト
- Headers: なし（`Accept-Language` は任意）
- Query params:
  - 【AI補完】`page`（integer, 任意, デフォルト `1`）: 未確定事項として `doc/pbi.md` に記載の通り、検索条件・ページングの要否は要合意。ここでは「11件目以降を取得する手段」として暫定的に追加
- JSON Body: なし

### レスポンス

**200 OK（正常系）**
```json
{
  "total_count": 12,
  "page": 1,
  "items": [
    { "employee_id": "E0001", "name": "山田太郎", "department": "営業部", "position": "課長" }
  ]
}
```
- `items` は最大10件、`employee_id` の昇順（PBIより）
- 【AI補完】`total_count` は検索条件に合致する全件数（ページングのため付与。未確定事項）
- 登録件数0件の場合は `items: []`, `total_count: 0` を200で返却

**400 Bad Request（異常系）**
- `page` が不正な値（0以下・数値以外など）の場合
```json
{ "error": { "code": "E0xx", "message": "page must be a positive integer" } }
```

**500 Internal Server Error**
```json
{ "error": { "code": "E500", "message": "internal server error" } }
```

---

## 2. 社員情報個別登録

`POST /employees`（PBI-2）

### リクエスト
- Headers: `Content-Type: application/json`
- JSON Body:

  | フィールド | 型 | 必須 |
  |---|---|---|
  | employee_id | string | ○ |
  | name | string | ○ |
  | department | string | ○ |
  | position | string | ○ |

### レスポンス

**201 Created（正常系）**
```json
{ "employee_id": "E0001", "name": "山田太郎", "department": "営業部", "position": "課長" }
```
- 氏名が既存の登録者と重複していてもエラーにしない（PBIより）

**400 Bad Request（異常系）**
- 必須項目（employee_id/name/department/position）のいずれかが未指定
```json
{
  "error": {
    "code": "E0xx",
    "message": "required field(s) missing",
    "details": [ { "field": "employee_id", "reason": "required" } ]
  }
}
```
- 【AI補完】`employee_id` の形式が不正な場合も同様に400（形式の詳細は未確定事項）

**409 Conflict（異常系）**
- 指定した `employee_id` が既に登録済み
```json
{ "error": { "code": "E0xx", "message": "employee_id already exists" } }
```

**500 Internal Server Error**
```json
{ "error": { "code": "E500", "message": "internal server error" } }
```

---

## 3. 社員情報編集

`PUT /employees/{employee_id}`（PBI-3）

### リクエスト
- Path params: `employee_id`（string, 必須。更新対象の特定に使用）
- Headers: `Content-Type: application/json`
- JSON Body:

  | フィールド | 型 | 必須 |
  |---|---|---|
  | name | string | ○ |
  | department | string | ○ |
  | position | string | ○ |
  | employee_id | — | **指定不可**（含まれていた場合は400。PBIより） |

### レスポンス

**200 OK（正常系）**
```json
{ "employee_id": "E0001", "name": "山田花子", "department": "開発部", "position": "部長" }
```
- 氏名が他の社員と重複していてもエラーにしない（PBIより）

**400 Bad Request（異常系）**
- リクエストボディに `employee_id` が含まれている
```json
{ "error": { "code": "E0xx", "message": "employee_id must not be specified in update request" } }
```
- 必須項目（name/department/position）のいずれかが未指定・空

**404 Not Found（異常系）**
- 【AI補完】パスパラメータの `employee_id` が未登録
```json
{ "error": { "code": "E0xx", "message": "employee not found" } }
```

**500 Internal Server Error**
```json
{ "error": { "code": "E500", "message": "internal server error" } }
```

---

## 4. 社員情報削除

`DELETE /employees/{employee_id}`（PBI-4、全項目【AI補完】: 受入条件の下書きに削除機能の記載がなかったため）

### リクエスト
- Path params: `employee_id`（string, 必須）
- JSON Body: なし

### レスポンス

**204 No Content（正常系）**
- ボディなし

**404 Not Found（異常系）**
- 指定した `employee_id` が未登録（削除済みを含む）
```json
{ "error": { "code": "E0xx", "message": "employee not found" } }
```

**500 Internal Server Error**
```json
{ "error": { "code": "E500", "message": "internal server error" } }
```

---

## 未確定事項（Step1からの持ち越し・追加分）

- `employee_id` の形式・採番ルール（桁数、英数字か数値か）
- 一覧取得APIの `page` / `total_count` の要否とページングの詳細仕様（本仕様書では暫定追加）
- 編集・削除APIで `employee_id` をパスパラメータとする設計の妥当性（クエリやボディでの指定を求める場合は要修正）
- 認証・認可ヘッダー（誰が「管理者」かの検証方法。本仕様書には含めていない）
- エラーコード（`E0xx`）の具体的な採番はStep3で確定
