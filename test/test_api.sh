#!/usr/bin/env bash
# 社員管理システムAPI 動作確認スクリプト（自習パート）
#
# 事前準備:
#   pip install -r requirements.txt
#   uvicorn src.main:app --reload
# （インメモリストアのため、必ずサーバ起動直後・未登録の状態からこのスクリプトを実行してください）
#
# 実行:
#   bash test/test_api.sh

set -uo pipefail

BASE_URL="${BASE_URL:-http://localhost:8000}"

run() {
  local id="$1" desc="$2" method="$3" path="$4" body="${5:-}" lang="${6:-}"
  echo "----------------------------------------------------------------"
  echo "[$id] $desc"
  echo "> $method $path"
  local lang_header=()
  if [ -n "$lang" ]; then
    lang_header=(-H "Accept-Language: $lang")
    echo "> Accept-Language: $lang"
  fi
  if [ -n "$body" ]; then
    echo "> body: $body"
    curl -s -o /tmp/resp_body.$$ -w "< status: %{http_code}\n" \
      -X "$method" "$BASE_URL$path" \
      -H "Content-Type: application/json" \
      "${lang_header[@]}" \
      -d "$body"
  else
    curl -s -o /tmp/resp_body.$$ -w "< status: %{http_code}\n" \
      -X "$method" "$BASE_URL$path" \
      "${lang_header[@]}"
  fi
  echo "< response: $(cat /tmp/resp_body.$$ 2>/dev/null)"
  rm -f /tmp/resp_body.$$
  echo
}

# --- 1. GET /employees ---

run "TC-101" "0件確認（サーバ起動直後）" GET "/employees"

# 一覧のページング・昇順確認用に11件登録（E1001〜E1011）
for i in $(seq 1 11); do
  eid=$(printf "E10%02d" "$i")
  curl -s -o /dev/null -X POST "$BASE_URL/employees" \
    -H "Content-Type: application/json" \
    -d "{\"employee_id\":\"$eid\",\"name\":\"テスト太郎$i\",\"department\":\"開発部\",\"position\":\"担当\"}"
done

run "TC-102" "11件登録済み・1ページ目は10件・昇順" GET "/employees?page=1"
run "TC-103" "11件登録済み・2ページ目は11件目の1件" GET "/employees?page=2"
run "TC-105" "pageが0（不正）→400" GET "/employees?page=0"
run "TC-106" "pageが数値以外（不正）→400" GET "/employees?page=abc"
run "TC-107" "既知の不一致: 範囲外page→仕様は400想定・実装は200+空配列" GET "/employees?page=99"

# --- 2. POST /employees ---

run "TC-201" "正常登録" POST "/employees" \
  '{"employee_id":"E2001","name":"登録太郎","department":"営業部","position":"課長"}'

run "TC-202" "氏名重複はOK（employee_idが別なら成功）" POST "/employees" \
  '{"employee_id":"E2002","name":"登録太郎","department":"人事部","position":"主任"}'

run "TC-203" "name未指定→400" POST "/employees" \
  '{"employee_id":"E2003","department":"営業部","position":"課長"}'

run "TC-204" "employee_id未指定→400" POST "/employees" \
  '{"name":"未登録花子","department":"営業部","position":"課長"}'

run "TC-205" "department未指定→400" POST "/employees" \
  '{"employee_id":"E2005","name":"未登録次郎","position":"課長"}'

run "TC-206" "position未指定→400" POST "/employees" \
  '{"employee_id":"E2006","name":"未登録三郎","department":"営業部"}'

run "TC-207" "employee_id重複→409" POST "/employees" \
  '{"employee_id":"E2001","name":"別人","department":"総務部","position":"係長"}'

# --- 3. PUT /employees/{employee_id} ---

run "TC-301" "正常更新" PUT "/employees/E2001" \
  '{"name":"登録太郎（更新）","department":"開発部","position":"部長"}'

run "TC-302" "他の社員と氏名重複してもOK" PUT "/employees/E2002" \
  '{"name":"登録太郎（更新）","department":"人事部","position":"主任"}'

run "TC-303" "ボディにemployee_idを含めると400" PUT "/employees/E2001" \
  '{"employee_id":"E2001","name":"登録太郎","department":"開発部","position":"部長"}'

run "TC-304" "存在しないemployee_id→404" PUT "/employees/E9999" \
  '{"name":"存在しない人","department":"開発部","position":"部長"}'

run "TC-305" "name未指定→400" PUT "/employees/E2001" \
  '{"department":"開発部","position":"部長"}'

run "TC-306" "department未指定→400" PUT "/employees/E2001" \
  '{"name":"登録太郎","position":"部長"}'

run "TC-307" "position未指定→400" PUT "/employees/E2001" \
  '{"name":"登録太郎","department":"開発部"}'

# --- 4. DELETE /employees/{employee_id} ---

run "TC-401" "正常削除" DELETE "/employees/E2001"
run "TC-402" "存在しないemployee_id→404" DELETE "/employees/E9999"
run "TC-403" "削除済みemployee_idを再度削除→404" DELETE "/employees/E2001"

# --- 5. 多言語対応（未実装・参考） ---

run "TC-501" "Accept-Language: en 指定（現状は未実装のため日本語固定文言が返る想定）" GET "/employees?page=abc" "" "en"

echo "----------------------------------------------------------------"
echo "全テストケースの実行が完了しました。各レスポンスを test/test_cases.md の期待結果と突き合わせてください。"
