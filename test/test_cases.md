# テストケース仕様書: 社員管理システムAPI

対象: `src/main.py`（FastAPIドラフト実装）
参照: `doc/pbi.md`, `doc/api_specification.md`, `doc/error_and_i18n_definition.md`

> 「現状の実装コード」列は `src/errors.py` の現行コード体系（`E001`=バリデーション全般 / `E002`=not found /
> `E003`=conflict / `E500`=internal）に基づく実測値です。`doc/error_and_i18n_definition.md` で定義した
> `E001〜E006` の粒度とは一致していません（Step3の申し送り事項どおり、未反映）。
> 本表は **HTTPステータスを一次判定基準**とし、エラーコード列は参考情報として扱ってください。

## 前提

- インメモリストアのため、サーバ再起動でデータはリセットされる
- TC-101（0件確認）は **サーバ起動直後・未登録の状態** で実行すること
- `test_api.sh` はこの順序で実行される前提

---

## 1. GET /employees（一覧取得）

| No | 分類 | 前提条件 (Given) | 操作 (When) | 期待結果 (Then) | 現状の実装コード |
|---|---|---|---|---|---|
| TC-101 | 正常 | 登録済み社員が0件（サーバ起動直後） | `GET /employees` | 200, `items: []`, `total_count: 0` | - |
| TC-102 | 正常 | 社員が11件登録されている | `GET /employees?page=1` | 200, `items`は10件、`employee_id`昇順、`total_count: 11` | - |
| TC-103 | 正常 | 社員が11件登録されている | `GET /employees?page=2` | 200, `items`は11件目の1件のみ | - |
| TC-104 | 正常 | 社員が5件登録されている（10件以下） | `GET /employees` | 200, 登録済み全件（5件）が昇順で返る | - |
| TC-105 | 異常 | - | `GET /employees?page=0` | 400（ページ指定が不正） | E001 |
| TC-106 | 異常 | - | `GET /employees?page=abc` | 400（ページ指定が不正） | E001 |
| TC-107 | 異常（仕様との既知の差分） | 総件数が10件のみ登録 | `GET /employees?page=99`（範囲外） | `doc/api_specification.md`上は400を想定 → 実装は200＋`items: []`を返す（既知の不一致、Step4レビューで指摘済み・未修正） | - |

## 2. POST /employees（個別登録）

| No | 分類 | 前提条件 (Given) | 操作 (When) | 期待結果 (Then) | 現状の実装コード |
|---|---|---|---|---|---|
| TC-201 | 正常 | `employee_id`が未登録、全項目指定 | `POST /employees` | 201, 登録内容がそのまま返る | - |
| TC-202 | 正常 | 既存社員と同じ`name`、`employee_id`は未登録 | `POST /employees` | 201（氏名重複はエラーにならない） | - |
| TC-203 | 異常 | `name`未指定 | `POST /employees` | 400 | E001 |
| TC-204 | 異常 | `employee_id`未指定 | `POST /employees` | 400 | E001 |
| TC-205 | 異常 | `department`未指定 | `POST /employees` | 400 | E001 |
| TC-206 | 異常 | `position`未指定 | `POST /employees` | 400 | E001 |
| TC-207 | 異常 | 既に登録済みの`employee_id`を指定 | `POST /employees` | 409（重複） | E003 |

## 3. PUT /employees/{employee_id}（編集）

| No | 分類 | 前提条件 (Given) | 操作 (When) | 期待結果 (Then) | 現状の実装コード |
|---|---|---|---|---|---|
| TC-301 | 正常 | `employee_id`が登録済み | `PUT /employees/{id}`（`name`/`department`/`position`のみ） | 200, 更新後の内容が返る | - |
| TC-302 | 正常 | 他の社員と同じ`name`を指定 | `PUT /employees/{id}` | 200（氏名重複はエラーにならない） | - |
| TC-303 | 異常 | - | `PUT /employees/{id}`（ボディに`employee_id`を含める） | 400（社員番号は指定不可） | E001 |
| TC-304 | 異常 | 存在しない`employee_id` | `PUT /employees/{存在しないid}` | 404 | E002 |
| TC-305 | 異常 | `name`未指定 | `PUT /employees/{id}` | 400 | E001 |
| TC-306 | 異常 | `department`未指定 | `PUT /employees/{id}` | 400 | E001 |
| TC-307 | 異常 | `position`未指定 | `PUT /employees/{id}` | 400 | E001 |

## 4. DELETE /employees/{employee_id}（削除）

| No | 分類 | 前提条件 (Given) | 操作 (When) | 期待結果 (Then) | 現状の実装コード |
|---|---|---|---|---|---|
| TC-401 | 正常 | `employee_id`が登録済み | `DELETE /employees/{id}` | 204, ボディなし | - |
| TC-402 | 異常 | 存在しない`employee_id` | `DELETE /employees/{存在しないid}` | 404 | E002 |
| TC-403 | 異常 | 直前に削除済みの`employee_id`を再度指定 | `DELETE /employees/{同じid}` | 404 | E002 |

## 5. 多言語対応（未実装・参考）

| No | 分類 | 前提条件 (Given) | 操作 (When) | 期待結果 (Then) | 備考 |
|---|---|---|---|---|---|
| TC-501 | 未実装 | `Accept-Language: en` を指定 | 任意のエラーを発生させるリクエスト | `doc/error_and_i18n_definition.md`の英語メッセージを期待 | 現在のドラフト実装は`Accept-Language`を参照せず、日本語固定文言のみ返却（未実装。テスト実行しても失敗する想定） |

---

## カバレッジ状況

- PBI-1〜4の受入条件（`doc/pbi.md`）は TC-101〜TC-403 で一通り網羅
- TC-107 は Step4静的レビューで指摘した仕様と実装の既知の不一致を検証用に残したもの（テスト自体は「現状はこう動く」ことの確認であり、合否判定ではない）
- TC-501 は多言語対応が未実装であることを明示するためのプレースホルダー
