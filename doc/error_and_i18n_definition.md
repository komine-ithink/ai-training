# 多言語文言定義書 ＆ エラー番号定義書: 社員管理システム

> 本ドキュメントは、Step1・2で定義した受入条件・API仕様に対応する文言・エラー番号をAI（Claude）が作成したものです。
> Step1・2と異なり受講者の下書きが無いため、行単位の【AI補完】マークは付けず、**全体を要確認**としています。
> 言語切り替えは `doc/api_specification.md` に記載の `Accept-Language` ヘッダー（`ja`/`en`/`zh`、未指定時は`ja`）を想定。

---

## 1. 文言定義表

正常系のレスポンスメッセージ。**中国語は参考訳（未検証）**として扱う。

| No | 用途 | 日本語 | 英語 | 中国語（参考訳・未検証） |
|---|---|---|---|---|
| M001 | 社員情報の登録完了 | 社員情報の登録が完了しました | Employee information has been registered successfully. | 员工信息登记完成。 |
| M002 | 社員情報の更新完了 | 社員情報の更新が完了しました | Employee information has been updated successfully. | 员工信息更新完成。 |
| M003 | 社員情報の削除完了 | 社員情報の削除が完了しました | Employee information has been deleted successfully. | 员工信息删除完成。 |

---

## 2. エラー番号定義表

**中国語は参考訳（未検証）**として扱う。

| エラーコード | エラー内容 | HTTPステータス | 日本語メッセージ | 英語メッセージ | 中国語メッセージ（参考訳・未検証） |
|---|---|---|---|---|---|
| E001 | 必須項目（氏名・社員番号・所属部署・役職）が未指定 | 400 | 必須項目（氏名・社員番号・所属部署・役職）が指定されていません | Required field(s) are missing (name, employee_id, department, position). | 缺少必填项（姓名、员工编号、所属部门、职位）。 |
| E002 | 社員番号の形式が不正 | 400 | 社員番号の形式が正しくありません | The employee_id format is invalid. | 员工编号格式不正确。 |
| E003 | 更新リクエストに社員番号が指定されている | 400 | 更新リクエストに社員番号を指定することはできません | employee_id must not be specified in the update request. | 更新请求中不能指定员工编号。 |
| E004 | 一覧取得のページ指定が不正 | 400 | ページ番号の指定が正しくありません | The page parameter is invalid. | 分页参数不正确。 |
| E005 | 社員番号が重複している（登録済み） | 409 | 指定した社員番号は既に登録されています | The specified employee_id already exists. | 指定的员工编号已存在。 |
| E006 | 指定された社員番号の社員が見つからない | 404 | 指定した社員番号の社員情報が見つかりません | Employee with the specified employee_id was not found. | 未找到指定员工编号的员工信息。 |
| E500 | サーバ内部エラー | 500 | サーバー内部でエラーが発生しました | An internal server error occurred. | 服务器内部发生错误。 |

---

## 3. 申し送り事項（要確認・未反映）

- **Step4ドラフト実装との差分**: 現在の `src/errors.py` / `src/main.py` は簡易的に
  `E001`(バリデーション全般・400全般をひとまとめ) / `E002`(not found) / `E003`(conflict) / `E500`(internal)
  のみを使用しており、本表の `E001〜E006` の粒度とは一致していません。
  実装に反映する場合は、エラー種別ごとにコードを出し分け、`Accept-Language` に応じて本表のメッセージを
  返すよう `errors.py` の見直しが必要です（未実施）。
- 中国語訳はネイティブ・翻訳者によるレビューを受けていない参考訳のため、実運用前に確認が必要です。
- `details`（フィールド単位のバリデーションエラー）配下のメッセージ多言語化は本表に含めていません。
