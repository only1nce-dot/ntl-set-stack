#!/bin/bash
# Test script to check environment and run market scan

echo "Testing market monitor environment..."
echo "Current directory: $(pwd)"
echo "Script directory: /Users/timothycox/.openclaw/workspaces/set"

# Check for sacred_assets.json
if [[ -f "sacred_assets.json" ]]; then
    echo "✅ sacred_assets.json found"
    echo "Assets: $(cat sacred_assets.json | jq -r '.all_assets | join(", ")')"
else
    echo "❌ sacred_assets.json not found"
fi

# Check for Alpaca env vars
if [[ -n "$ALPACA_API_KEY" ]] && [[ -n "$ALPACA_SECRET_KEY" ]]; then
    echo "✅ Alpaca credentials found in environment"
else
    echo "❌ Alpaca credentials not in environment"
fi

# Test API access if credentials exist
if [[ -n "$ALPACA_API_KEY" ]] && [[ -n "$ALPACA_SECRET_KEY" ]]; then
    echo "Testing Alpaca API access..."
    curl -s -X GET "https://data.alpaca.markets/v2/stocks/AAPL/trades/latest" \
        -H "APCA-API-KEY-ID: $ALPACA_API_KEY" -H "APCA-API-SECRET-KEY: $ALPACA_SECRET_KEY" | jq .
fi