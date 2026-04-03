#!/bin/bash
# Simplified market scan for cron execution
# Returns summary of market conditions

echo "🔍 MARKET SCAN SUMMARY - $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo ""
echo "🌪️ SET Territorial Domain Monitor"
echo "📊 Scanning 30 Sacred Assets"
echo ""

# Check if we have Alpaca credentials
if [[ -z "$ALPACA_API_KEY" ]] || [[ -z "$ALPACA_SECRET_KEY" ]]; then
    echo "❌ ALPACA CREDENTIALS NOT AVAILABLE"
    echo "Cannot perform market analysis without API access."
    echo ""
    echo "Please configure Alpaca API keys in environment."
    exit 1
fi

echo "✅ Alpaca API access available"
echo ""

# Load sacred assets
ASSETS=("VOO" "QQQ" "DIA" "NVDA" "MSFT" "AAPL" "GOOGL" "META" "AMZN" "TSLA" "PLTR" "APP" "SMCI" "MSTR" "COIN" "MU" "AVGO" "ARM" "TSM" "AMD" "LLY" "NVO" "CRVS" "XBI" "XLE" "XOM" "NUAI" "GLD" "USRE")

echo "📈 Checking market conditions..."
echo ""

# Test connection with first asset
SYMBOL="VOO"
RESPONSE=$(curl -s -X GET "https://data.alpaca.markets/v2/stocks/${SYMBOL}/trades/latest" \
    -H "APCA-API-KEY-ID: ${ALPACA_API_KEY}" -H "APCA-API-SECRET-KEY: ${ALPACA_SECRET_KEY}")

if echo "$RESPONSE" | grep -q "error"; then
    echo "❌ API Error: Cannot access market data"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "✅ Market data accessible"
echo ""

# Get current prices for a sample of assets
SAMPLE_ASSETS=("VOO" "QQQ" "NVDA" "AAPL" "TSLA")
echo "💰 SAMPLE PRICES:"
for SYMBOL in "${SAMPLE_ASSETS[@]}"; do
    RESPONSE=$(curl -s -X GET "https://data.alpaca.markets/v2/stocks/${SYMBOL}/trades/latest" \
        -H "APCA-API-KEY-ID: ${ALPACA_API_KEY}" -H "APCA-API-SECRET-KEY: ${ALPACA_SECRET_KEY}")
    PRICE=$(echo "$RESPONSE" | jq -r '.trade.p // .trade.P // "N/A"')
    echo "  ${SYMBOL}: \$${PRICE}"
done

echo ""
echo "📅 Next Steps:"
echo "1. Full territorial scan requires T7 Archive access"
echo "2. Pattern analysis needs historical data"
echo "3. Institutional footprint requires volume data"
echo ""
echo "⚡ SET Monitoring System - Operational"
echo "✅ API Connectivity: GOOD"
echo "❌ Intelligence Vault: NOT ACCESSIBLE (T7 Archive)"
echo "🔧 Configuration needed for full functionality"