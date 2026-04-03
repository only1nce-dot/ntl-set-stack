#!/bin/bash
set -euo pipefail

# Load environment
ENV_FILE="${HOME}/.openclaw/.env"
if [[ -f "$ENV_FILE" ]]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Telegram credentials
SET_BOT_TOKEN="8682010049:AAECUmYdNfKKYo7BsOAXe6S0c9iCMuzyxGE"
SET_CHAT_ID="7453367919"

# Send test message
curl -s -X POST "https://api.telegram.org/bot${SET_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${SET_CHAT_ID}" \
    -d "text=⚡ Testing SET's communication link - Anpu has successfully integrated SET into the stack." \
    -d "parse_mode=HTML" > /dev/null 2>&1

echo "Test message sent to SetianWealth_Bot"