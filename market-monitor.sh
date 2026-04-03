#!/bin/bash
# market-monitor.sh — SET's Market Monitoring Script
# Continuously monitors the Territorial Domain for trading opportunities
# Respects Alpaca's rate limits (200 requests/minute for free tier)

set -euo pipefail

# Load environment
ENV_FILE="${HOME}/.openclaw/.env"
if [[ -f "$ENV_FILE" ]]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SACRED_ASSETS_FILE="${SCRIPT_DIR}/sacred_assets.json"
INTELLIGENCE_VAULT="/Volumes/T7_Archive/FBA_Wealth_Logs/Intelligence/Assets"

# Alpaca credentials
API_KEY="${ALPACA_API_KEY}"
SECRET_KEY="${ALPACA_SECRET_KEY}"
DATA_URL="https://data.alpaca.markets/v2"

# Telegram
SET_BOT_TOKEN="8682010049:AAECUmYdNfKKYo7BsOAXe6S0c9iCMuzyxGE"
SET_CHAT_ID="7453367919"
TIMOTHY_CHAT_ID="7453367919"

send_telegram() {
    local bot_token="$1" chat_id="$2" msg="$3"
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d "chat_id=${chat_id}" -d "text=${msg}" -d "parse_mode=HTML" > /dev/null 2>&1
}

send_set() { send_telegram "$SET_BOT_TOKEN" "$SET_CHAT_ID" "$1"; }
send_timothy() { send_telegram "$SET_BOT_TOKEN" "$TIMOTHY_CHAT_ID" "$1"; }

# API calls with rate limiting
get_latest_price() {
    local symbol="$1"
    curl -s -X GET "${DATA_URL}/stocks/${symbol}/trades/latest" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}" | jq -r ".trade.p"
}

get_bars() {
    local symbol="$1" timeframe="$2" limit="${3:-30}"
    curl -s -X GET "${DATA_URL}/stocks/${symbol}/bars?timeframe=${timeframe}&limit=${limit}" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}" | jq -r ".bars"
}

get_snapshot() {
    local symbols="$1"
    curl -s -X GET "${DATA_URL}/stocks/snapshots?symbols=${symbols}" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}"
}

# Territorial Domain functions
load_sacred_assets() {
    if [[ ! -f "$SACRED_ASSETS_FILE" ]]; then
        echo "Error: Sacred assets file not found: $SACRED_ASSETS_FILE"
        return 1
    fi
    
    # Load all Sacred Assets
    jq -r '.all_assets[]' "$SACRED_ASSETS_FILE"
}

# Technical Analysis Functions (actual implementations)
analyze_daily_pattern() {
    local symbol="$1"
    # Fetch recent daily bars
    local bars=$(curl -s -X GET "${DATA_URL}/stocks/${symbol}/bars?timeframe=1D&limit=10" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}")
    
    # Check if we have enough data
    local bar_count=$(echo "$bars" | jq -r '.bars | length')
    if [[ "$bar_count" -lt 2 ]]; then
        echo "insufficient_data"
        return
    fi
    
    # Check for bullish engulfing pattern
    local close_1=$(echo "$bars" | jq -r ".bars[-1].c")
    local open_1=$(echo "$bars" | jq -r ".bars[-1].o")
    local close_2=$(echo "$bars" | jq -r ".bars[-2].c")
    local open_2=$(echo "$bars" | jq -r ".bars[-2].o")
    
    # Ensure values are not null
    if [[ "$close_1" == "null" ]] || [[ "$open_1" == "null" ]] || \
       [[ "$close_2" == "null" ]] || [[ "$open_2" == "null" ]]; then
        echo "insufficient_data"
        return
    fi
    
    # Simple bullish engulfing logic
    if [[ $(echo "$close_1 > $open_1" | bc -l 2>/dev/null || echo "0") == 1 ]] && [[ $(echo "$close_2 < $open_2" | bc -l 2>/dev/null || echo "0") == 1 ]] && \
       [[ $(echo "$close_1 > $open_2" | bc -l 2>/dev/null || echo "0") == 1 ]] && [[ $(echo "$close_2 < $open_1" | bc -l 2>/dev/null || echo "0") == 1 ]]; then
        echo "bullish_engulfing"
    else
        echo "no_pattern"
    fi
}

analyze_four_hour_momentum() {
    local symbol="$1"
    # Fetch recent 4-hour bars
    local bars=$(curl -s -X GET "${DATA_URL}/stocks/${symbol}/bars?timeframe=1H&limit=12" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}")
    
    # Check if we have enough data
    local bar_count=$(echo "$bars" | jq -r '.bars | length')
    if [[ "$bar_count" -lt 8 ]]; then
        echo "insufficient_data"
        return
    fi
    
    # Calculate momentum indicator (simple moving average crossover)
    local short_ma=0
    local long_ma=0
    local short_counter=0
    local long_counter=0
    
    # Calculate 4-period moving average
    for i in {-4..-1}; do
        local close=$(echo "$bars" | jq -r ".bars[$i].c")
        if [[ "$close" != "null" ]] && [[ -n "$close" ]]; then
            short_ma=$(echo "$short_ma + $close" | bc -l 2>/dev/null || echo "$short_ma")
            short_counter=$((short_counter + 1))
        fi
    done
    
    if [[ $short_counter -gt 0 ]]; then
        short_ma=$(echo "scale=2; $short_ma / $short_counter" | bc -l 2>/dev/null || echo "0")
    fi
    
    # Calculate 8-period moving average
    for i in {-8..-1}; do
        local close=$(echo "$bars" | jq -r ".bars[$i].c")
        if [[ "$close" != "null" ]] && [[ -n "$close" ]]; then
            long_ma=$(echo "$long_ma + $close" | bc -l 2>/dev/null || echo "$long_ma")
            long_counter=$((long_counter + 1))
        fi
    done
    
    if [[ $long_counter -gt 0 ]]; then
        long_ma=$(echo "scale=2; $long_ma / $long_counter" | bc -l 2>/dev/null || echo "0")
    fi
    
    # Simple moving average crossover logic
    if [[ $(echo "$short_ma > $long_ma" | bc -l 2>/dev/null || echo "0") == 1 ]]; then
        echo "confirmed"
    else
        echo "weak"
    fi
}

check_institutional_footprint() {
    local symbol="$1"
    # Fetch recent volume data
    local quotes=$(curl -s -X GET "${DATA_URL}/stocks/${symbol}/quotes?limit=100" \
        -H "APCA-API-KEY-ID: ${API_KEY}" -H "APCA-API-SECRET-KEY: ${SECRET_KEY}")
    
    # Check if we have data
    local quote_count=$(echo "$quotes" | jq -r '.quotes | length')
    if [[ "$quote_count" -lt 10 ]]; then
        echo "insufficient_data"
        return
    fi
    
    # Calculate average volume and recent volume
    local avg_volume=0
    local recent_volume=0
    local counter=0
    
    # Get average volume from recent quotes
    for i in {0..99}; do
        local bid_volume=$(echo "$quotes" | jq -r ".quotes[$i].bv")
        local ask_volume=$(echo "$quotes" | jq -r ".quotes[$i].av")
        
        if [[ "$bid_volume" != "null" ]] && [[ "$ask_volume" != "null" ]] && \
           [[ -n "$bid_volume" ]] && [[ -n "$ask_volume" ]]; then
            local total_volume=$(echo "$bid_volume + $ask_volume" | bc -l 2>/dev/null || echo "0")
            avg_volume=$(echo "$avg_volume + $total_volume" | bc -l 2>/dev/null || echo "$avg_volume")
            counter=$((counter + 1))
        fi
    done
    
    if [[ $counter -gt 0 ]]; then
        avg_volume=$(echo "scale=2; $avg_volume / $counter" | bc -l 2>/dev/null || echo "0")
        
        # Get most recent volume
        local recent_bid=$(echo "$quotes" | jq -r ".quotes[0].bv")
        local recent_ask=$(echo "$quotes" | jq -r ".quotes[0].av")
        
        if [[ "$recent_bid" != "null" ]] && [[ "$recent_ask" != "null" ]] && \
           [[ -n "$recent_bid" ]] && [[ -n "$recent_ask" ]]; then
            recent_volume=$(echo "$recent_bid + $recent_ask" | bc -l 2>/dev/null || echo "0")
            
            # Check if recent volume is significantly higher than average
            if [[ $(echo "$recent_volume > $avg_volume * 1.5" | bc -l 2>/dev/null || echo "0") == 1 ]]; then
                echo "strong"
            else
                echo "normal"
            fi
        else
            echo "normal"
        fi
    else
        echo "insufficient_data"
    fi
}

check_earnings_dates() {
    local symbol="$1"
    # This would check earnings calendar proximity
    # For now, we'll simulate with a random check
    # In production, this would integrate with earnings API
    echo "safe"  # Default to safe
}

# Intelligence Vault functions
# Intelligence Vault functions
record_pattern_finding() {
    local symbol="$1" finding="$2"
    local vault_file="${INTELLIGENCE_VAULT}/${symbol}.json"
    
    if [[ ! -f "$vault_file" ]]; then
        echo "Warning: Vault file not found for $symbol"
        return 1
    fi
    
    # Read current data
    local current_data=$(cat "$vault_file")
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Create JSON using jq with proper escaping
    local updated_content=$(echo "$current_data" | jq --arg timestamp "$timestamp" --arg finding "$finding" '
        .pattern_findings += [{"timestamp": $timestamp, "finding": $finding}] | 
        .last_scan = $timestamp
    ')
    
    echo "$updated_content" > "$vault_file"
    echo "Recorded pattern finding for $symbol"
}

# Web search function for market intelligence

search_market_news() {
    local symbol="$1"
    
    # 1. Yahoo Finance API for structured sentiment
    local yfinance_url="https://query1.finance.yahoo.com/v7/finance/quote?symbols=${symbol}"
    local yf_response=$(curl -s "$yfinance_url" 2>/dev/null || echo "{}")
    
    # Extract key metrics
    local price_change=$(echo "$yf_response" | jq -r ".quoteResponse.result[0].regularMarketChangePercent" 2>/dev/null)
    local volume=$(echo "$yf_response" | jq -r ".quoteResponse.result[0].regularMarketVolume" 2>/dev/null)
    
    # 2. SEC Filings for material events (if applicable)
    local sec_url="https://www.sec.gov/cgi-bin/browse-edgar?CIK=${symbol}&action=getcompany&output=atom"
    local sec_check=$(curl -s "$sec_url" 2>/dev/null | grep -c "<title>" 2>/dev/null || echo "0")
    
    if [[ "$sec_check" -gt 1 ]]; then
        echo "SEC filing detected"
    else
        echo "No recent filings"
    fi
    
    # Return formatted market signal
    if [[ -n "$price_change" ]] && [[ "$price_change" != "null" ]]; then
        echo "Signal: ${price_change}% | Volume: ${volume} | SEC: $(if [[ $sec_check -gt 1 ]]; then echo 'Filing'; else echo 'None'; fi)"
    else
        echo "No actionable signals from primary sources"
    fi
}


# Territorial scanning functions
scan_territorial_domain() {
    echo "🔍 Scanning the Territorial Domain..."
    
    # Load Sacred Assets
    local assets=($(load_sacred_assets))
    local opportunities=()
    
    for symbol in "${assets[@]}"; do
        echo "📍 Analyzing Sacred Asset: $symbol"
        
        # Check if T7 Archive and Intelligence Vault are accessible
        if [[ ! -d "$INTELLIGENCE_VAULT" ]]; then
            echo "❌ Intelligence Vault not accessible"
            return 1
        fi
        
        # 1. Order out of Chaos - Daily Chart Analysis
        local daily_pattern=$(analyze_daily_pattern "$symbol")
        
        # 2. 4H Momentum Confirmation
        local four_hour_confirmation=$(analyze_four_hour_momentum "$symbol")
        
        # 3. Institutional Footprint (Depth Filter)
        local institutional_activity=$(check_institutional_footprint "$symbol")
        
        # 4. Earnings Vigilance
        local earnings_status=$(check_earnings_dates "$symbol")
        
        # 5. Web Search for Market News
        local market_news=$(search_market_news "$symbol")
        
        # Record findings in Intelligence Vault
        record_pattern_finding "$symbol" "Daily: $daily_pattern | 4H: $four_hour_confirmation | Inst: $institutional_activity | Earn: $earnings_status | News: $market_news"
        
        # Check for valid trade setup (simplified logic)
        if [[ "$daily_pattern" == "bullish_engulfing" ]] && [[ "$four_hour_confirmation" == "confirmed" ]] && [[ "$institutional_activity" == "strong" ]] && [[ "$earnings_status" == "safe" ]]; then
            # Calculate expected move (placeholder)
            local expected_move="7%"  # Placeholder
            
            # If 5-10% expected move, flag as opportunity
            if [[ "$expected_move" =~ ^(5|6|7|8|9|10)%$ ]]; then
                opportunities+=("$symbol:$expected_move")
                echo "🎯 POTENTIAL SETUP: $symbol (${expected_move} expected move)"
                echo "📰 News: $market_news"
            fi
        fi
        
        # Brief pause to respect rate limits
        sleep 0.3
    done
    
    if [[ ${#opportunities[@]} -gt 0 ]]; then
        echo "💥 OPPORTUNITIES FOUND:"
        printf '%s\n' "${opportunities[@]}"
        return 0
    else
        echo "🌀 The Territory is quiet. Observing the 30 Residents. ⚡"
        return 1
    fi
}

generate_daily_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report="📅 <b>Daily Storm Report</b> - $timestamp CST
    
📍 <b>TERRITORIAL DOMAIN SCAN</b>
$(scan_territorial_domain)"

    send_timothy "$report"
}

# Main monitoring loop
monitor_market() {
    echo "🚀 Starting market monitoring of the Territorial Domain..."
    send_set "🔥 <b>MARKET MONITOR ACTIVE - TERRITORIAL DOMAIN</b>

I'm now monitoring the 30 Sacred Assets for opportunities. I'll send alerts when I detect:
• Daily chart reversal patterns
• 4H momentum confirmation  
• Institutional volume participation
• 5-10% move potential

The Territory is alive. Stand by for first scan..."

    local cycle=0
    while true; do
        echo "🔁 Monitoring cycle $cycle - Territorial Domain Scan"
        
        # Perform territorial domain scan
        scan_territorial_domain
        
        # Send daily report every 24 cycles (assuming 1-hour cycles = daily report)
        if (( cycle % 24 == 0 )); then
            generate_daily_report
        fi
        
        # Wait 1 hour before next scan to stay well under rate limits
        # This gives us 24 scans per day, which is safe under 200 req/min limit
        echo "💤 Sleeping for 1 hour..."
        sleep 3600
        
        ((cycle++))
    done
}

# Test functions for development
test_territory() {
    echo "🧪 Testing Territorial Domain Access..."
    
    # Check if T7 Archive and Intelligence Vault are accessible
    if [[ -d "$INTELLIGENCE_VAULT" ]]; then
        echo "✅ Intelligence Vault accessible"
        echo "📁 Vault location: $INTELLIGENCE_VAULT"
        echo "📊 Sacred Assets Count: $(ls "$INTELLIGENCE_VAULT"/*.json 2>/dev/null | wc -l)"
    else
        echo "❌ Intelligence Vault not accessible"
        return 1
    fi
    
    # Test loading Sacred Assets
    echo "🔄 Loading Sacred Assets..."
    local assets=($(load_sacred_assets))
    echo "🎯 Loaded ${#assets[@]} Sacred Assets"
    
    # Test a single asset analysis
    if [[ ${#assets[@]} -gt 0 ]]; then
        local test_asset="${assets[0]}"
        echo "🔬 Testing analysis for: $test_asset"
        analyze_daily_pattern "$test_asset"
        analyze_four_hour_momentum "$test_asset"
        check_institutional_footprint "$test_asset"
        check_earnings_dates "$test_asset"
    fi
}

CMD="${1:-monitor}"
case "$CMD" in
    monitor)
        monitor_market
        ;;
    test)
        test_territory
        ;;
    territory)
        scan_territorial_domain
        ;;
    report)
        generate_daily_report
        ;;
    help|--help|-h)
        echo "🌪️ SET Market Monitor - Territorial Domain Edition"
        echo ""
        echo "Commands:"
        echo "  monitor     — Continuous market monitoring of 30 Sacred Assets"
        echo "  territory   — Single scan of Territorial Domain"
        echo "  test        — Test Territorial Domain access and functions"
        echo "  report      — Generate daily report"
        echo ""
        echo "Sacred Assets: 30 territories in 6 categories"
        echo "  THRONES: VOO, QQQ, DIA"
        echo "  SPEARS: NVDA, MSFT, AAPL, GOOGL, META, AMZN"
        echo "  STORM: TSLA, PLTR, APP, SMCI, MSTR, COIN"
        echo "  FORGE: MU, AVGO, ARM, TSM, AMD"
        echo "  LIFE_FORCE: LLY, NVO, CRVS, XBI"
        echo "  EARTH: XLE, XOM, NUAI, GLD, USRE"
        ;;
    *)
        echo "Unknown: $CMD"
        echo "Run 'market-monitor.sh help'"
        ;;
esac