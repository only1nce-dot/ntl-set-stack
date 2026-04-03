#!/bin/bash
# set-trade.sh — SET's Trading Execution Script
# Location: ~/.openclaw/scripts/set-trade.sh
# Governor of the Storm executes here

set -euo pipefail

# Load environment
ENV_FILE="${HOME}/.openclaw/.env"
if [[ -f "$ENV_FILE" ]]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Alpaca credentials
API_KEY="${ALPACA_API_KEY}"
SECRET_KEY="${ALPACA_SECRET_KEY}"
PAPER_TRADE_URL="https://paper-api.alpaca.markets/v2"
LIVE_TRADE_URL="https://api.alpaca.markets/v2"
DATA_URL="https://data.alpaca.markets/v2"

# Telegram
SET_BOT_TOKEN="8682010049:AAECUmYdNfKKYo7BsOAXe6S0c9iCMuzyxGE"
SET_CHAT_ID="7453367919"

send_telegram() {
    local bot_token="$1" chat_id="$2" msg="$3"
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d "chat_id=${chat_id}" -d "text=${msg}" -d "parse_mode=HTML" > /dev/null 2>&1
}
send_set() { send_telegram "$SET_BOT_TOKEN" "$SET_CHAT_ID" "$1"; }

# API calls
get_account() {
    curl -s -X GET "${PAPER_TRADE_URL}/account" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}"
}

get_positions() {
    curl -s -X GET "${PAPER_TRADE_URL}/positions" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}"
}

get_quote() {
    curl -s -X GET "${DATA_URL}/stocks/${1}/trades?limit=1" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}" | jq '.trades[0]'
}

get_bars() {
    curl -s -X GET "${DATA_URL}/stocks/${1}/bars?limit=5" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}" | jq '.bars'
}

place_order() {
    curl -s -X POST "${PAPER_TRADE_URL}/orders" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"symbol\":\"${1}\",\"qty\":\"${2}\",\"side\":\"${3}\",\"type\":\"market\",\"time_in_force\":\"day\"}"
}

get_order() {
    curl -s -X GET "${PAPER_TRADE_URL}/orders/${1}" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}"
}

archive_trade() {
    local data="$1" month=$(date '+%Y/%m')
    mkdir -p "/Volumes/T7_Archive/FBA_Wealth_Logs/Records/${month}"
    local req_id=$(echo "$data" | jq -r '.alpaca.request_id // "unknown"')
    echo "$data" > "/Volumes/T7_Archive/FBA_Wealth_Logs/Records/${month}/FBA_$(date '+%Y-%m-%d')_${req_id}.yaml"
    
    # Write to T7 Pending folder for Anpu to detect
    local pending_file="/Volumes/T7_Archive/FBA_Wealth_Logs/Pending/FBA_$(date '+%Y%m%d_%H%M%S')_${req_id}.pending"
    echo "$data" > "$pending_file"
}

CMD="${1:-help}"
case "$CMD" in
    account)
        echo "=== ALPACA ACCOUNT ==="
        get_account | jq '.account_number, .status, .cash, .buying_power, .portfolio_value'
        ;;
    positions)
        echo "=== POSITIONS ==="
        get_positions | jq '.'
        ;;
    help|--help|-h)
        echo "🐊 SET Trading Script"
        echo ""
        echo "Commands:"
        echo "  account              — Account info"
        echo "  positions            — Current holdings"
        echo "  quote SYMBOL         — Latest trade price"
        echo "  bars SYMBOL          — Last 5 bars (OHLC)"
        echo "  buy SYMBOL QTY       — Market buy"
        echo "  sell SYMBOL QTY      — Market sell"
        ;;
    quote)
        SYMBOL="${2:-}"
        if [[ -z "$SYMBOL" ]]; then echo "Usage: quote SYMBOL"; exit 1; fi
        echo "=== QUOTE: $SYMBOL ==="
        get_quote "$SYMBOL" | jq '{price: .p, size: .s, time: .t}'
        ;;
    bars)
        SYMBOL="${2:-}"
        if [[ -z "$SYMBOL" ]]; then echo "Usage: bars SYMBOL"; exit 1; fi
        echo "=== BARS: $SYMBOL ==="
        get_bars "$SYMBOL" | jq '.[] | {open: .o, high: .h, low: .l, close: .c, volume: .v, time: .t}'
        ;;
    buy)
        SYMBOL="${2:-}" QTY="${3:-}"
        if [[ -z "$SYMBOL" || -z "$QTY" ]]; then echo "Usage: buy SYMBOL QTY"; exit 1; fi
        echo "=== BUY ${QTY} shares ${SYMBOL} ==="
        ORDER=$(place_order "$SYMBOL" "$QTY" "buy")
        echo "Order: $ORDER"
        ORDER_ID=$(echo "$ORDER" | jq -r '.id')
        REQUEST_ID=$(echo "$ORDER" | jq -r '.request_id')
        echo "Order ID: $ORDER_ID | Request ID: $REQUEST_ID"
        echo "⏳ Waiting for fill..."
        sleep 3
        STATUS=$(get_order "$ORDER_ID")
        FQTY=$(echo "$STATUS" | jq -r '.filled_qty // "0"')
        FPRICE=$(echo "$STATUS" | jq -r '.filled_avg_price // "0"')
        STAT=$(echo "$STATUS" | jq -r '.status')
        echo "Status: $STAT | Filled: $FQTY @ $FPRICE"
        if [[ "$STAT" == "filled" && "$FQTY" != "null" && -n "$FQTY" && "$FQTY" != "0" ]]; then
            TOTAL=$(echo "$FQTY * $FPRICE" | bc)
            send_set "✅ TRADE FILLED

📊 BUY ${FQTY} shares ${SYMBOL}
💵 \$${FPRICE}/share | Total: \$${TOTAL}
🆔 Order: ${ORDER_ID}
🔖 Request: ${REQUEST_ID}"
            ARCHIVE="---
id: FBA_$(date '+%Y-%m-%d')_${REQUEST_ID}
timestamp: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')
mode: PAPER
bucket: TO_BE_ASSIGNED
trade:
  action: BUY
  symbol: ${SYMBOL}
  quantity: ${FQTY}
  price_per_share: ${FPRICE}
  total_value: ${TOTAL}
  currency: USD
alpaca:
  order_id: ${ORDER_ID}
  request_id: ${REQUEST_ID}
  status: ${STAT}
archived_by: Anpu
archived_at: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')
"
            archive_trade "$ARCHIVE"
            echo "✅ Archived"
        fi
        ;;
    sell)
        SYMBOL="${2:-}" QTY="${3:-}"
        if [[ -z "$SYMBOL" || -z "$QTY" ]]; then echo "Usage: sell SYMBOL QTY"; exit 1; fi
        echo "=== SELL ${QTY} shares ${SYMBOL} ==="
        ORDER=$(place_order "$SYMBOL" "$QTY" "sell")
        ORDER_ID=$(echo "$ORDER" | jq -r '.id')
        REQUEST_ID=$(echo "$ORDER" | jq -r '.request_id')
        echo "⏳ Waiting for fill..."
        sleep 3
        STATUS=$(get_order "$ORDER_ID")
        FQTY=$(echo "$STATUS" | jq -r '.filled_qty // "0"')
        FPRICE=$(echo "$STATUS" | jq -r '.filled_avg_price // "0"')
        STAT=$(echo "$STATUS" | jq -r '.status')
        if [[ "$STAT" == "filled" && "$FQTY" != "null" && -n "$FQTY" && "$FQTY" != "0" ]]; then
            TOTAL=$(echo "$FQTY * $FPRICE" | bc)
            send_set "✅ TRADE FILLED

📊 SELL ${FQTY} shares ${SYMBOL}
💵 \$${FPRICE}/share | Total: \$${TOTAL}
🆔 Order: ${ORDER_ID}
🔖 Request: ${REQUEST_ID}"
            ARCHIVE="---
id: FBA_$(date '+%Y-%m-%d')_${REQUEST_ID}
timestamp: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')
mode: PAPER
bucket: TO_BE_ASSIGNED
trade:
  action: SELL
  symbol: ${SYMBOL}
  quantity: ${FQTY}
  price_per_share: ${FPRICE}
  total_value: ${TOTAL}
  currency: USD
alpaca:
  order_id: ${ORDER_ID}
  request_id: ${REQUEST_ID}
  status: ${STAT}
archived_by: Anpu
archived_at: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')
"
            archive_trade "$ARCHIVE"
            echo "✅ Archived"
        fi
        ;;
    *)
        echo "Unknown: $CMD"
        echo "Run 'set-trade.sh help'"
        ;;
esac
