#!/bin/bash
# notify_kuma.sh: Push a status update to an Uptime Kuma push monitor.

set -euo pipefail

USAGE="Usage: notify_kuma.sh <up|down> <message> <push-url>"

STATUS="${1:?$USAGE}"
MSG="${2:?$USAGE}"
PUSH_URL="${3:?$USAGE}"

# Simple "space to +" encoding for the query string
ENCODED_MSG="${MSG// /+}"

FULL_URL="${PUSH_URL}?status=${STATUS}&msg=${ENCODED_MSG}&ping="

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FULL_URL")

if [ "$HTTP_CODE" -ne 200 ]; then
    echo "WARNING: Uptime Kuma push failed with HTTP $HTTP_CODE" >&2
fi
