#!/bin/bash
#
# SET Market Data Fetch Script (On-Demand)
# Purpose: Fetch current market data for specified tickers
# Data Source: Yahoo Finance web pages
# Output: JSON data to T7 Archive
# Author: Anpu v3.0
# Date: 2026-04-03

set -e

# Configuration
T7_FETCH_DIR="/Volumes/T7_Archive/FBA_Wealth_Logs/Market_Data/Fetched"
LOG_FILE="/Volumes/T7_Archive/FBA_Wealth_Logs/Market_Data/fetch_log.log"

# Ensure directory exists
mkdir -p "$T7_FETCH_DIR"

# Display usage
if [[ $# -eq 0 ]]; then
    echo "SET Market Data Fetch - On-Demand Data Retrieval"
    echo ""
    echo "Usage: $0 TICKER [TICKER ...]"
    echo ""
    echo "Examples:"
    echo "  $0 VOO"
    echo "  $0 VOO QQQ NVDA"
    echo "  $0 NVDA"
    echo ""
    echo "Output: Writes JSON data to $T7_FETCH_DIR"
    echo "       Log file: $LOG_FILE"
    echo ""
    exit 0
fi

# Get tickers from command line
TICKERS=("$@")

# Timestamp
TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%SZ")
DATE_SUFFIX=$(date +"%Y-%m-%d")

echo "[$TIMESTAMP] Fetching market data for ${#TICKERS[@]} ticker(s)" | tee -a "$LOG_FILE"

# Function to fetch and extract Yahoo Finance data
fetch_yahoo_data() {
    local ticker="$1"
    local url="https://finance.yahoo.com/quote/${ticker}"
    local output_file="${T7_FETCH_DIR}/${DATE_SUFFIX}_${ticker}.json"

    echo "  Fetching $ticker from Yahoo Finance..." | tee -a "$LOG_FILE"

    # Fetch page using curl (simulating web_fetch)
    local response=$(curl -s -L \
        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
        --compressed \
        "$url" 2>/dev/null)

    if [[ -z "$response" || ${#response} -lt 10000 ]]; then
        echo "  ✗ FAILED: Page too small or empty for $ticker" | tee -a "$LOG_FILE"
        return 1
    fi

    # Extract data from embedded JSON
    # This extracts the price, change, volume from the HTML-embedded data

    # Try to extract symbol, price, change, volume from page
    local price=$(echo "$response" | grep -o "\"symbol\":\"${ticker}\".*?\"regularMarketPrice\":{\"raw\":[0-9.]+" | grep -o '[0-9.]*$' | head -1)
    local change=$(echo "$response" | grep -o "\"symbol\":\"${ticker}\".*?\"regularMarketChange\":{\"raw\":[-0-9.]+" | grep -o '[-0-9.]*$' | head -1)
    local change_pct=$(echo "$response" | grep -o "\"symbol\":\"${ticker}\".*?\"regularMarketChangePercent\":{\"raw\":[-0-9.]+" | grep -o '[-0-9.]*$' | head -1)
    local volume=$(echo "$response" | grep -o "\"symbol\":\"${ticker}\".*?\"regularMarketVolume\":{\"raw\":[0-9]+" | grep -o '[0-9]*$' | head -1)

    # If first extraction failed, try alternative approach
    if [[ -z "$price" ]]; then
        price=$(echo "$response" | grep -o 'regularMarketPrice.*?raw":([0-9.]*)' | grep -o '[0-9.]*$' | head -1)
    fi

    if [[ -z "$change" ]]; then
        change=$(echo "$response" | grep -o 'regularMarketChange.*?raw":([-0-9.]*)' | grep -o '[-0-9.]*$' | head -1)
    fi

    if [[ -z "$change_pct" ]]; then
        change_pct=$(echo "$response" | grep -o 'regularMarketChangePercent.*?raw":([-0-9.]*)' | grep -o '[-0-9.]*$' | head -1)
    fi

    if [[ -z "$volume" ]]; then
        volume=$(echo "$response" | grep -o 'regularMarketVolume.*?raw":([0-9]*)' | grep -o '[0-9]*$' | head -1)
    fi

    # Default values if extraction failed
    [[ -z "$price" ]] && price="N/A"
    [[ -z "$change" ]] && change="N/A"
    [[ -z "$change_pct" ]] && change_pct="N/A"
    [[ -z "$volume" ]] && volume="N/A"

    # Create JSON output
    cat > "$output_file" << EOF
{
  "ticker": "$ticker",
  "timestamp": "$TIMESTAMP",
  "source": "yahoo_finance",
  "fetch_url": "$url",
  "data": {
    "price": "$price",
    "change": "$change",
    "change_pct": "$change_pct",
    "volume": "$volume",
    "prev_close": "N/A",
    "day_high": "N/A",
    "day_low": "N/A",
    "week_52_high": "N/A",
    "week_52_low": "N/A"
  },
  "fetched_by": "SET",
  "mode": "paper_trail"
}
EOF

    if [[ "$price" != "N/A" ]]; then
        echo "  ✓ SUCCESS: $ticker at \$$price ($change_pct%)" | tee -a "$LOG_FILE"
        echo "    Saved to: $output_file" | tee -a "$LOG_FILE"
        return 0
    else
        echo "  ✗ FAILED: Could not extract price data for $ticker" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Fetch data for each ticker
success_count=0
for ticker in "${TICKERS[@]}"; do
    if fetch_yahoo_data "$ticker"; then
        success_count=$((success_count + 1))
    else
        echo "  Skipping $ticker - fetch failed" | tee -a "$LOG_FILE"
    fi
    echo "" | tee -a "$LOG_FILE"
done

# Summary
echo "[$TIMESTAMP] Fetch complete: $success_count of ${#TICKERS[@]} tickers retrieved successfully" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

exit 0