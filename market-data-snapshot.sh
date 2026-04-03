#!/bin/bash
#
# SET Market Data Snapshot Script (Option A)
# Purpose: Hourly snapshot of market data for 30 Sacred Assets
# Data Source: Yahoo Finance API v7
# Output: JSON snapshots to T7 Archive
# Author: Anpu v3.0
# Date: 2026-04-03
#

set -e

# Configuration
T7_MARKET_DATA="/Volumes/T7_Archive/FBA_Wealth_Logs/Market_Data"
SNAPSHOT_DIR="${T7_MARKET_DATA}/Snapshots"
LOG_FILE="${T7_MARKET_DATA}/snapshot_log.log"
SET_WORKSPACE="/Users/timothycox/.openclaw/workspaces/set"

# Ensure directories exist
mkdir -p "$SNAPSHOT_DIR"
mkdir -p "$T7_MARKET_DATA"

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%SZ")
SNAPSHOT_FILE="${SNAPSHOT_DIR}/$(date +"%Y-%m-%d_%H%M").json"

# Sacred Assets list (from sacred_assets.json)
ASSETS=("VOO" "QQQ" "DIA" "NVDA" "MSFT" "AAPL" "GOOGL" "META" "AMZN" "TSLA" "PLTR" "APP" "SMCI" "MSTR" "COIN" "MU" "AVGO" "ARM" "TSM" "AMD" "LLY" "NVO" "CRVS" "XBI" "XLE" "XOM" "NUAI" "GLD" "USRE")

NUM_ASSETS=${#ASSETS[@]}

echo "[$TIMESTAMP] Starting market data snapshot for $NUM_ASSETS assets" >> "$LOG_FILE"

# Helper: Fetch data from Yahoo Finance API
fetch_yahoo_data() {
    local ticker="$1"
    local url="https://query1.finance.yahoo.com/v7/finance/quote?symbols=${ticker}&fields=regularMarketPrice,regularMarketChange,regularMarketChangePercent,regularMarketVolume,fiftyTwoWeekLow,fiftyTwoWeekHigh,regularMarketPreviousClose"

    local response=$(curl -s -L \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
        "$url" 2>/dev/null)

    # Extract price
    local price=$(echo "$response" | grep -o '"regularMarketPrice":{"raw":[0-9.]*' | grep -o '[0-9.]*$' | head -1)

    if [[ -z "$price" ]]; then
        price="N/A"
    fi

    # Extract change
    local change=$(echo "$response" | grep -o '"regularMarketChange":{"raw":[-0-9.]*' | grep -o '[-0-9.]*$' | head -1)
    if [[ -z "$change" ]]; then
        change="N/A"
    fi

    # Extract percentage change
    local change_pct=$(echo "$response" | grep -o '"regularMarketChangePercent":{"raw":[-0-9.]*' | grep -o '[-0-9.]*$' | head -1)
    if [[ -z "$change_pct" ]]; then
        change_pct="N/A"
    fi

    # Extract volume
    local volume=$(echo "$response" | grep -o '"regularMarketVolume":{"raw":[0-9]*' | grep -o '[0-9]*$' | head -1)
    if [[ -z "$volume" ]]; then
        volume="N/A"
    fi

    # Extract 52 week low
    local week52_low=$(echo "$response" | grep -o '"fiftyTwoWeekLow":{"raw":[0-9.]*' | grep -o '[0-9.]*$' | head -1)
    if [[ -z "$week52_low" ]]; then
        week52_low="N/A"
    fi

    # Extract 52 week high
    local week52_high=$(echo "$response" | grep -o '"fiftyTwoWeekHigh":{"raw":[0-9.]*' | grep -o '[0-9.]*$' | head -1)
    if [[ -z "$week52_high" ]]; then
        week52_high="N/A"
    fi

    # Extract previous close
    local prev_close=$(echo "$response" | grep -o '"regularMarketPreviousClose":{"raw":[0-9.]*' | grep -o '[0-9.]*$' | head -1)
    if [[ -z "$prev_close" ]]; then
        prev_close="N/A"
    fi

    # Output JSON snippet
    echo "    \"$ticker\": {"
    echo "      \"price\": \"$price\","
    echo "      \"change\": \"$change\","
    echo "      \"change_pct\": \"$change_pct\","
    echo "      \"volume\": \"$volume\","
    echo "      \"week_52_low\": \"$week52_low\","
    echo "      \"week_52_high\": \"$week52_high\","
    echo "      \"prev_close\": \"$prev_close\","
    echo "      \"source\": \"yahoo_finance_api\""
    echo "    }"

    if [[ "$price" != "N/A" ]]; then
        echo "[$TIMESTAMP] $ticker: \$$price ($change_pct%)" >> "$LOG_FILE"
        return 0
    else
        echo "[$TIMESTAMP] WARNING: Failed to fetch $ticker" >> "$LOG_FILE"
        return 1
    fi
}

# Initialize JSON structure
cat > "$SNAPSHOT_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "source": "yahoo_finance_api_v7",
  "mode": "paper_trail",
  "assets": {
EOF

# Fetch data for all assets
COMPLETED=0
for asset in "${ASSETS[@]}"; do
    COMPLETED=$((COMPLETED + 1))
    fetch_yahoo_data "$asset"

    # Add comma if not last asset
    if [[ $COMPLETED -lt $NUM_ASSETS ]]; then
        echo ","
    fi
done

# Close JSON structure
cat >> "$SNAPSHOT_FILE" << EOF
  }
}
EOF

# Verify JSON is valid
if jq . "$SNAPSHOT_FILE" > /dev/null 2>&1; then
    echo "[$TIMESTAMP] Snapshot successfully created: $SNAPSHOT_FILE" >> "$LOG_FILE"
    echo "[$TIMESTAMP] JSON validation: PASS" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] ERROR: JSON validation failed for $SNAPSHOT_FILE" >> "$LOG_FILE"
fi

# Keep only last 168 hours (7 days) of snapshots
find "$SNAPSHOT_DIR" -name "*.json" -mtime +7 -delete 2>/dev/null

echo "[$TIMESTAMP] Market data snapshot complete. Assets processed: $NUM_ASSETS" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

exit 0