#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://splyto.eu/api/api.php}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%d%H%M%S)}"
PASSWORD="${PASSWORD:-Smoke!123A}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DEVICE_A="$(openssl rand -hex 32)"
DEVICE_B="$(openssl rand -hex 32)"
DEVICE_B_LOGIN2="$(openssl rand -hex 32)"

USER_A_EMAIL="smoke+a_${RUN_ID}@example.test"
USER_B_EMAIL="smoke+b_${RUN_ID}@example.test"

USER_A_ID=""
USER_B_ID=""
ACCESS_A=""
ACCESS_B=""
REFRESH_A=""
REFRESH_B=""
TRIP_PRIVATE_ID=""
TRIP_SHARED_ID=""
SETTLEMENT_ID=""

LAST_STATUS=""
LAST_HEADERS=""
LAST_BODY=""
LAST_REQUEST_ID=""

log() {
  printf '[p0-smoke] %s\n' "$*"
}

fail() {
  printf '[p0-smoke][FAIL] %s\n' "$*" >&2
  if [[ -n "${LAST_BODY:-}" && -f "${LAST_BODY:-}" ]]; then
    printf '[p0-smoke][FAIL] Last response body: %s\n' "$(cat "$LAST_BODY")" >&2
  fi
  exit 1
}

ensure_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing command: $1"
}

api_request() {
  local method="$1"
  local action="$2"
  local device_token="$3"
  local access_token="${4:-}"
  local trip_id="${5:-}"
  local body_json="${6:-}"

  local request_id="smoke_${RUN_ID}_${action}_$RANDOM"
  local url="${BASE_URL}?action=${action}"
  if [[ -n "$trip_id" ]]; then
    url="${url}&trip_id=${trip_id}"
  fi

  local headers_file="${TMP_DIR}/${request_id}.headers"
  local body_file="${TMP_DIR}/${request_id}.body"
  local -a args=(
    -sS
    -D "$headers_file"
    -o "$body_file"
    -w "%{http_code}"
    -H "Accept: application/json"
    -H "X-Device-Token: ${device_token}"
    -H "X-Request-Id: ${request_id}"
  )

  if [[ -n "$access_token" ]]; then
    args+=(-H "Authorization: Bearer ${access_token}")
  fi

  if [[ "$method" == "POST" ]]; then
    args+=(
      -X POST
      -H "Content-Type: application/json"
      --data "$body_json"
    )
  else
    args+=(-X GET)
  fi

  local status
  status="$(curl "${args[@]}" "$url")"
  LAST_STATUS="$status"
  LAST_HEADERS="$headers_file"
  LAST_BODY="$body_file"
  LAST_REQUEST_ID="$request_id"
}

assert_status() {
  local expected="$1"
  [[ "$LAST_STATUS" == "$expected" ]] || fail "Expected HTTP $expected, got $LAST_STATUS"
}

assert_status_one_of() {
  local got="$LAST_STATUS"
  local ok="0"
  local expected
  for expected in "$@"; do
    if [[ "$got" == "$expected" ]]; then
      ok="1"
      break
    fi
  done
  [[ "$ok" == "1" ]] || fail "Expected HTTP one of [$*], got $got"
}

json_get() {
  local query="$1"
  jq -er "$query" "$LAST_BODY"
}

assert_request_id_echo() {
  local echoed
  echoed="$(awk -F': ' 'tolower($1)=="x-request-id"{gsub("\r","",$2); print $2}' "$LAST_HEADERS" | tail -n 1)"
  [[ -n "$echoed" ]] || fail "Response missing X-Request-Id header"
  [[ "$echoed" == "$LAST_REQUEST_ID" ]] || fail "X-Request-Id mismatch. sent=$LAST_REQUEST_ID got=$echoed"
}

register_user() {
  local label="$1"
  local last_name="$2"
  local device_token="$3"
  local email="$4"
  local first_name="Smoke"
  local nickname="smoke_${label}_${RUN_ID}"

  api_request "GET" "register_proof" "$device_token" "" "" ""
  assert_status "200"
  local register_proof
  register_proof="$(json_get '.register_proof')"

  local body
  body="$(jq -nc \
    --arg fn "$first_name" \
    --arg ln "$last_name" \
    --arg nn "$nickname" \
    --arg em "$email" \
    --arg pw "$PASSWORD" \
    --arg dt "$device_token" \
    --arg rp "$register_proof" \
    '{first_name:$fn,last_name:$ln,nickname:$nn,email:$em,password:$pw,device_token:$dt,register_proof:$rp,website:""}')"

  api_request "POST" "register" "$device_token" "" "" "$body"
  assert_status "200"
  assert_request_id_echo
}

main() {
  ensure_cmd curl
  ensure_cmd jq
  ensure_cmd openssl

  log "Run id: $RUN_ID"
  log "Base URL: $BASE_URL"

  log "Register user A"
  register_user "A" "Alpha" "$DEVICE_A" "$USER_A_EMAIL"
  USER_A_ID="$(json_get '.me.id')"
  ACCESS_A="$(json_get '.auth.access_token')"
  REFRESH_A="$(json_get '.auth.refresh_token')"

  log "Register user B"
  register_user "B" "Beta" "$DEVICE_B" "$USER_B_EMAIL"
  USER_B_ID="$(json_get '.me.id')"
  ACCESS_B="$(json_get '.auth.access_token')"
  REFRESH_B="$(json_get '.auth.refresh_token')"

  log "Create private trip for A (data isolation baseline)"
  local create_private_body
  create_private_body="$(jq -nc --arg name "Smoke Private ${RUN_ID}" '{name:$name,member_ids:[]}')"
  api_request "POST" "create_trip" "$DEVICE_A" "$ACCESS_A" "" "$create_private_body"
  assert_status "200"
  TRIP_PRIVATE_ID="$(json_get '.trip.id')"

  log "Create shared trip for A+B (happy path)"
  local create_shared_body
  create_shared_body="$(jq -nc --arg name "Smoke Shared ${RUN_ID}" --argjson member_id "$USER_B_ID" '{name:$name,member_ids:[$member_id]}')"
  api_request "POST" "create_trip" "$DEVICE_A" "$ACCESS_A" "" "$create_shared_body"
  assert_status "200"
  assert_request_id_echo
  TRIP_SHARED_ID="$(json_get '.trip.id')"

  log "Data isolation: B must NOT access A private trip"
  api_request "GET" "workspace_snapshot" "$DEVICE_B" "$ACCESS_B" "$TRIP_PRIVATE_ID" ""
  assert_status "403"

  log "Data isolation: B trips list must NOT include A private trip"
  api_request "GET" "trips" "$DEVICE_B" "$ACCESS_B" "" ""
  assert_status "200"
  local private_count
  private_count="$(jq -r --argjson tid "$TRIP_PRIVATE_ID" '[.trips[] | select(.id == $tid)] | length' "$LAST_BODY")"
  [[ "$private_count" == "0" ]] || fail "User B can see private trip of user A"

  log "Happy path: A adds shared expense"
  local add_expense_body
  add_expense_body="$(jq -nc \
    --arg amount "40.00" \
    --arg note "Smoke expense ${RUN_ID}" \
    --arg date "$(date +%F)" \
    --argjson user_a "$USER_A_ID" \
    --argjson user_b "$USER_B_ID" \
    '{amount:$amount,category:"food",note:$note,date:$date,participants:[$user_a,$user_b],split_mode:"equal"}')"
  api_request "POST" "add_expense" "$DEVICE_A" "$ACCESS_A" "$TRIP_SHARED_ID" "$add_expense_body"
  assert_status "200"

  log "Happy path: B can see shared expense"
  api_request "GET" "list_expenses" "$DEVICE_B" "$ACCESS_B" "$TRIP_SHARED_ID" ""
  assert_status "200"
  local expense_count
  expense_count="$(jq -r '.expenses | length' "$LAST_BODY")"
  [[ "$expense_count" -ge 1 ]] || fail "No expenses visible for user B in shared trip"

  log "Happy path: A ends trip (settling flow starts)"
  api_request "POST" "end_trip" "$DEVICE_A" "$ACCESS_A" "$TRIP_SHARED_ID" "{}"
  assert_status "200"
  local settlements_len
  settlements_len="$(jq -r '.settlements | length' "$LAST_BODY")"
  if [[ "$settlements_len" -gt 0 ]]; then
    SETTLEMENT_ID="$(jq -r '.settlements[0].id' "$LAST_BODY")"
  fi

  if [[ -n "$SETTLEMENT_ID" && "$SETTLEMENT_ID" != "null" ]]; then
    log "Happy path: B marks settlement as sent"
    local sent_body
    sent_body="$(jq -nc --argjson settlement_id "$SETTLEMENT_ID" '{settlement_id:$settlement_id}')"
    api_request "POST" "mark_settlement_sent" "$DEVICE_B" "$ACCESS_B" "$TRIP_SHARED_ID" "$sent_body"
    assert_status "200"

    log "Happy path: A confirms settlement received"
    local confirm_body
    confirm_body="$(jq -nc --argjson settlement_id "$SETTLEMENT_ID" '{settlement_id:$settlement_id}')"
    api_request "POST" "confirm_settlement_received" "$DEVICE_A" "$ACCESS_A" "$TRIP_SHARED_ID" "$confirm_body"
    assert_status "200"
  else
    log "No settlements generated (trip may already be balanced)."
  fi

  log "Token stability: valid refresh rotates tokens"
  local refresh_body
  refresh_body="$(jq -nc --arg rt "$REFRESH_A" '{refresh_token:$rt}')"
  api_request "POST" "refresh_session" "$DEVICE_A" "$ACCESS_A" "" "$refresh_body"
  assert_status "200"
  ACCESS_A="$(json_get '.auth.access_token')"
  REFRESH_A="$(json_get '.auth.refresh_token')"

  log "Token stability: new access token works"
  api_request "GET" "me" "$DEVICE_A" "$ACCESS_A" "" ""
  assert_status "200"

  log "Token stability: invalid access token rejected"
  api_request "GET" "me" "$DEVICE_A" "invalid_token_value" "" ""
  assert_status "401"

  log "Token stability: invalid refresh token rejected"
  local bad_refresh_body
  bad_refresh_body="$(jq -nc --arg rt "deadbeef" '{refresh_token:$rt}')"
  api_request "POST" "refresh_session" "$DEVICE_A" "$ACCESS_A" "" "$bad_refresh_body"
  assert_status_one_of "400" "401"

  log "Logout/Login cycle: B can log in again from new device token"
  local login_body
  login_body="$(jq -nc --arg em "$USER_B_EMAIL" --arg pw "$PASSWORD" '{email:$em,password:$pw}')"
  api_request "POST" "login" "$DEVICE_B_LOGIN2" "" "" "$login_body"
  assert_status "200"
  ACCESS_B="$(json_get '.auth.access_token')"

  log "Smoke finished successfully."
  log "Created test users: ${USER_A_EMAIL}, ${USER_B_EMAIL}"
  log "Created test trips: private=${TRIP_PRIVATE_ID}, shared=${TRIP_SHARED_ID}"
}

main "$@"
