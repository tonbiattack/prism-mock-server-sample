#!/usr/bin/env bash
# Prism モックサーバーへの API テストスクリプト
# 使い方: bash scripts/test-api.sh

BASE_URL="http://localhost:4010"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

run() {
  local label="$1"
  shift
  echo -e "\n${BLUE}=== ${label} ===${NC}"
  echo -e "${YELLOW}$ $*${NC}"
  "$@"
  echo
}

echo -e "${GREEN}=== 正常系 ===${NC}"

run "GET /todos (200)" \
  curl -s -X GET "${BASE_URL}/todos" -H "Accept: application/json"

run "GET /todos?status=open (200)" \
  curl -s -X GET "${BASE_URL}/todos?status=open" -H "Accept: application/json"

run "GET /todos/1 (200)" \
  curl -s -X GET "${BASE_URL}/todos/1" -H "Accept: application/json"

run "POST /todos (201)" \
  curl -s -X POST "${BASE_URL}/todos" \
    -H "Content-Type: application/json" \
    -d '{"title": "テストタスク"}'

run "PATCH /todos/1 (200)" \
  curl -s -X PATCH "${BASE_URL}/todos/1" \
    -H "Content-Type: application/json" \
    -d '{"status": "done"}'

run "DELETE /todos/1 (204)" \
  curl -s -o /dev/null -w "HTTP Status: %{http_code}" \
    -X DELETE "${BASE_URL}/todos/1"

echo -e "\n\n${RED}=== エラー系（Prefer: code=XXX で強制指定）===${NC}"

run "400 Bad Request (POST /todos)" \
  curl -s -X POST "${BASE_URL}/todos" \
    -H "Content-Type: application/json" \
    -H "Prefer: code=400" \
    -d '{"title": "テスト"}'

run "401 Unauthorized (GET /todos/1)" \
  curl -s -X GET "${BASE_URL}/todos/1" \
    -H "Prefer: code=401"

run "403 Forbidden (GET /todos/1)" \
  curl -s -X GET "${BASE_URL}/todos/1" \
    -H "Prefer: code=403"

run "404 Not Found (GET /todos/1)" \
  curl -s -X GET "${BASE_URL}/todos/1" \
    -H "Prefer: code=404"

run "409 Conflict (PATCH /todos/1)" \
  curl -s -X PATCH "${BASE_URL}/todos/1" \
    -H "Content-Type: application/json" \
    -H "Prefer: code=409" \
    -d '{"status": "done"}'

run "422 Unprocessable Entity (POST /todos)" \
  curl -s -X POST "${BASE_URL}/todos" \
    -H "Content-Type: application/json" \
    -H "Prefer: code=422" \
    -d '{"title": "テスト"}'

run "500 Internal Server Error (GET /todos/1)" \
  curl -s -X GET "${BASE_URL}/todos/1" \
    -H "Prefer: code=500"

run "500 Internal Server Error (POST /todos)" \
  curl -s -X POST "${BASE_URL}/todos" \
    -H "Content-Type: application/json" \
    -H "Prefer: code=500" \
    -d '{"title": "テスト"}'

run "500 Internal Server Error (DELETE /todos/1)" \
  curl -s -o /dev/null -w "HTTP Status: %{http_code}" \
    -X DELETE "${BASE_URL}/todos/1" \
    -H "Prefer: code=500"

echo -e "\n\n${GREEN}全テスト完了${NC}"
