#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../secrets"

# Decrypt and strip any whitespace
TOKEN=$(agenix -d hetzner-api-token.age 2>/dev/null | tr -d '\n\r\t ')

# Validate length
if [ ${#TOKEN} -ne 64 ]; then
    echo "ERROR: Token must be 64 chars (got ${#TOKEN})" >&2
    exit 1
fi

echo -n "$TOKEN"
