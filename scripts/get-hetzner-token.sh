#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../secrets"

# Use rage with pinentry-gnome3 for non-interactive passphrase prompts.
# rage reads PINENTRY_PROGRAM from the environment (set via home.sessionVariables).
TOKEN=$(rage -d -i ~/.ssh/id_ed25519 hetzner-api-token.age | tr -d '\n\r\t ')

# Validate length
if [ ${#TOKEN} -ne 64 ]; then
    echo "ERROR: Token must be 64 chars (got ${#TOKEN})" >&2
    exit 1
fi

echo -n "$TOKEN"
