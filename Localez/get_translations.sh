#!/bin/bash
CONFIG="${SRCROOT}/Localez/.localez"
if [ ! -f "$CONFIG" ]; then
  echo "warning: .localez config not found, skipping translation sync" >&2
  exit 0
fi
source "$CONFIG"

TOKEN_FILE="${SRCROOT}/Localez/.localez_token"
if [ ! -f "$TOKEN_FILE" ]; then
  echo "warning: ~/.localez_token not found, skipping translation sync" >&2
  exit 0
fi

if ! curl -fsSL \
  -H "Authorization: Bearer $(cat "$TOKEN_FILE")" \
  -o "$XCSTRINGS_PATH" \
  "${BASE_URL}/api/projects/${PROJECT_ID}/export"; then
  echo "warning: Translation sync failed (server unreachable or token expired) — building with cached file" >&2
fi
