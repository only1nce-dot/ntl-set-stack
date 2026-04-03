#!/bin/bash
# set-file-trades.sh - Comprehensive Trade Filing System
# Handles paper and live trading with complete bucket tracking
# Guardian of Amenti - SET (@SetianWealth_Bot)

set -euo pipefail

# ============================================================
# CONFIGURATION
# ============================================================

# Trading Mode - HARD-CODED SAFETY
# NEVER MODIFY THESE MANUALLY - Use TRADING_MODE environment variable
TRADING_MODE="${TRADING_MODE:-PAPER}"  # PAPER or LIVE

# Hard-stop: Never mix paper and live
if [[ "$TRADING_MODE" != "PAPER" ]] && [[ "$TRADING_MODE" != "LIVE" ]]; then
    echo "❌ INVALID TRADING MODE: $TRADING_MODE"
    echo "Must be PAPER or LIVE"
    exit 1
fi

# Alpaca API Configuration (from env)
ENV_FILE="${HOME}/.openclaw/.env"
if [[ -f "$ENV_FILE" ]]; then
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

API_KEY="${ALPACA_API_KEY:-}"
SECRET_KEY="${ALPACA_SECRET_KEY:-}"

# Mode-specific configuration
if [[ "$TRADING_MODE" == "PAPER" ]]; then
    TRADE_DIR="/Volumes/T7_Archive/FBA_Wealth_Logs/PAPER"
    ALPACA_URL="https://paper-api.alpaca.markets/v2"
    DATA_URL="https://data.alpaca.markets/v2"
else
    TRADE_DIR="/Volumes/T7_Archive/FBA_Wealth_Logs/LIVE"
    ALPACA_URL="https://api.alpaca.markets/v2"
    DATA_URL="https://data.alpaca.markets/v2"
fi

FBA_WEALTH_LOGS="/Volumes/T7_Archive/FBA_Wealth_Logs"
ANPU_WORKSPACE="${HOME}/.openclaw/workspaces/set"
BUCKETS_DIR="${FBA_WEALTH_LOGS}/Buckets"

# Telegram (SET bot for execution alerts)
SET_BOT_TOKEN="8682010049:AAECUmYdNfKKYo7BsOAXe6S0c9iCMuzyxGE"
SET_CHAT_ID="7453367919"

# File locking
BASE_LOCK_FILE="/tmp/fba_bucket_lock"

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

log_trading() {
    local level="$1" message="$2"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    echo "[$timestamp] [$level] $message"
}

send_telegram() {
    local bot_token="$1" chat_id="$2" msg="$3"
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d "chat_id=${chat_id}" -d "text=${msg}" -d "parse_mode=Markdown" > /dev/null 2>&1
}

send_set() {
    send_telegram "$SET_BOT_TOKEN" "$SET_CHAT_ID" "$1"
}

# ============================================================
# BUCKET CLASSIFICATION - AUTO-ASSIGNMENT WITH REASONING
# ============================================================

get_bucket_for_symbol() {
    local symbol="$1"

    # THRONES (ETFs) → FOUNDATION
    case "$symbol" in
        VOO|QQQ|DIA|GLD|XOM|USRE)
            echo "FOUNDATION"
            ;;
    esac

    # SPEARS (Tech) + FORGE (Semis) + LIFE (Bio) + EARTH (Energy ETF) → GROWTH
    case "$symbol" in
        NVDA|MSFT|AAPL|GOOGL|META|AMZN)
            echo "GROWTH"
            ;;
    esac

    case "$symbol" in
        MU|AVGO|ARM|TSM|AMD)
            echo "GROWTH"
            ;;
    esac

    case "$symbol" in
        LLY|NVO|CRVS|XBI|XLE)
            echo "GROWTH"
            ;;
    esac

    # STORM (High Volatility) → STORM
    case "$symbol" in
        TSLA|PLTR|APP|SMCI|MSTR|COIN)
            echo "STORM"
            ;;
    esac

    # Default fallback
    echo "GROWTH"
}

get_bucket_reasoning() {
    local symbol="$1"
    local bucket="$(get_bucket_for_symbol "$symbol")"

    case "$symbol" in
        VOO)
            echo "Index tracking for broad market stability (SPY equivalent)"
            ;;
        QQQ)
            echo "Tech sector index exposure (Nasdaq-100 tracking)"
            ;;
        DIA)
            echo "Blue-chip index stability (Dow Jones tracking)"
            ;;
        NVDA)
            echo "AI infrastructure revolution leader (High conviction tech position)"
            ;;
        TSLA)
            echo "EV disruption + robotaxi pivot (Maximum volatility)"
            ;;
        PLTR)
            echo "Defense + gov software data platform (Government contract wins)"
            ;;
        *)
            echo "Asset classified as ${bucket} based on sector and volatility profile"
            ;;
    esac
}

get_bucket_allocation() {
    local bucket="$1"
    case "$bucket" in
        FOUNDATION) echo "0.50" ;;
        GROWTH)    echo "0.35" ;;
        STORM)     echo "0.15" ;;
        *)         echo "0.00" ;;
    esac
}

get_bucket_seed() {
    local bucket="$1"
    case "$bucket" in
        FOUNDATION) echo "123.00" ;;
        GROWTH)    echo "86.10" ;;
        STORM)     echo "36.90" ;;
        *)         echo "0.00" ;;
    esac
}

# ============================================================
# BUCKET TRACKING FUNCTIONS
# ============================================================

get_bucket_info() {
    local bucket="$1"
    local positions_file="${BUCKETS_DIR}/${bucket}/positions.yaml"

    if [[ ! -f "$positions_file" ]]; then
        echo "holdings:0.00|cash:0.00|total:0.00"
        return
    fi

    local holdings=$(grep "^total_value:" "$positions_file" 2>/dev/null | awk '{print $2 || "0.00"}')
    local cash=$(grep "^cash_available:" "$positions_file" 2>/dev/null | awk '{print $2 || "0.00"}')
    local total=$(echo "$holdings + $cash" | bc -l 2>/dev/null || echo "0.00")

    echo "holdings:$holdings|cash:$cash|total:$total"
}

check_bucket_overflow() {
    local symbol="$1"
    local trade_value="$2"
    local action="${3:-BUY}"  # BUY or SELL

    local bucket_name="$(get_bucket_for_symbol "$symbol")"

    if [[ "$action" == "SELL" ]]; then
        return 0
    fi

    local bucket_info=$(get_bucket_info "$bucket_name")
    local current_total=$(echo "$bucket_info" | cut -d: -f5)

    # Get total portfolio value
    local foundation_total=$(get_bucket_info "FOUNDATION" | cut -d: -f5)
    local growth_total=$(get_bucket_info "GROWTH" | cut -d: -f5)
    local storm_total=$(get_bucket_info "STORM" | cut -d: -f5)
    local portfolio_total=$(echo "$foundation_total + $growth_total + $storm_total + $trade_value" | bc -l 2>/dev/null || echo "246.00")

    # Calculate new allocation percentage
    local new_bucket_total=$(echo "$current_total + $trade_value" | bc -l)
    local new_allocation=$(echo "scale=4; $new_bucket_total / $portfolio_total" | bc)
    local max_allocation=$(get_bucket_allocation "$bucket_name")

    # Check if over allocation (5% tolerance)
    local max_threshold=$(echo "scale=4; $max_allocation * 1.05" | bc)

    if (( $(echo "$new_allocation > $max_threshold" | bc -l) )); then
        # OVERFLOW DETECTED
        local reasoning=$(get_bucket_reasoning "$symbol")

        cat << EOF
=== OVERFLOW WARNING: $bucket_name ===

CURRENT STATE:
  Portfolio Total: \$$portfolio_total
  $bucket_name Current: \$$current_total ($(echo "scale=2; ($current_total / $portfolio_total) * 100" | bc)%)
  Target Allocation: $(echo "scale=0; ($max_allocation * 100)" | bc)%

PROPOSED TRADE:
  Symbol: $symbol
  Trade Value: \$$trade_value
  New $bucket_name Total: \$$new_bucket_total
  New Allocation: $(echo "scale=2; $new_allocation * 100" | bc)%

REASONS FOR OVERFLOW:
  1. This trade would push $bucket_name beyond $(echo "scale=0; ($max_allocation * 100)" | bc)% allocation target
  2. Over-allocation increases bucket concentration risk
  3. Violates three-bucket diversification strategy
  4. $reasoning

OPTIONS:
  1. Reduce trade size to stay within allocation
  2. Sell from $bucket_name first to create room
  3. Request Sovereign Seal override if intentional
EOF

        log_trading "WARN" "Overflow detected: $bucket_name would be $(echo "scale=1; $new_allocation * 100" | bc)% (max $(echo "scale=0; ($max_allocation * 100)" | bc)%)"
        return 1
    fi

    return 0
}

update_bucket_positions() {
    local bucket="$1"
    local symbol="$2"
    local quantity="$3"
    local price="$4"
    local total="$5"
    local action="$6"  # BUY or SELL

    local positions_file="${BUCKETS_DIR}/${bucket}/positions.yaml"
    local lock_file="${BASE_LOCK_FILE}_positions_${bucket}"

    (
        flock 9 || exit 1

        # Read current state
        local current_total=$(grep "^total_value:" "$positions_file" 2>/dev/null | awk '{print $2 || "0.00"}')
        local current_cash=$(grep "^cash_available:" "$positions_file" 2>/dev/null | awk '{print $2 || "0.00"}')

        # Update totals
        local new_total new_cash
        if [[ "$action" == "BUY" ]]; then
            new_total=$(echo "$current_total + $total" | bc -l)
            new_cash=$(echo "$current_cash - $total" | bc -l)
        else
            new_total=$(echo "$current_total - $total" | bc -l)
            new_cash=$(echo "$current_cash + $total" | bc -l)
        fi

        # Write updated file
        cat > "$positions_file" << EOF
# ${bucket} Bucket — Positions
bucket: ${bucket}
target_allocation: $(get_bucket_allocation "$bucket")
last_updated: $(date '+%Y-%m-%d')
holdings: []
total_value: $(printf "%.2f" "$new_total")
cash_available: $(printf "%.2f" "$new_cash")
seed_target: $(get_bucket_seed "$bucket")
last_trade: $action $symbol $quantity shares @ \$${price}
EOF

        log_trading "INFO" "Updated $bucket positions: total=\$$new_total, cash=\$$(printf "%.2f" "$new_cash")"

    ) 9>"$lock_file"
}

append_bucket_history() {
    local bucket="$1"
    local trade_data="$2"

    local history_file="${BUCKETS_DIR}/${bucket}/history.yaml"
    local lock_file="${BASE_LOCK_FILE}_history_${bucket}"

    (
        flock 9 || exit 1

        echo "$trade_data" >> "$history_file"

        log_trading "INFO" "Appended to $bucket history"

    ) 9>"$lock_file"
}

generate_bucket_reasoning() {
    local symbol="$1"
    local bucket_name="$(get_bucket_for_symbol "$symbol")"
    local reasoning=$(get_bucket_reasoning "$symbol")

    cat << EOF
<reasoning>
  bucket_assignment: ${bucket_name}
  classification: ${reasoning}

  delta: [price movement analysis - 4H and Daily chart alignment]
  volatility_index: [VI value - ATR or VIX-based]
  risk_to_reward: [calculated R:R ratio - target / stop_loss]

  bucket_justification:
    - Asset classified as ${bucket_name}
    - Fits ${bucket_name} allocation mandate: $(echo "scale=0; ($(get_bucket_allocation "$bucket_name") * 100)" | bc)%
    - ${reasoning}
</reasoning>
EOF
}

generate_trade_yaml() {
    local mode="$1"
    local action="$2"
    local symbol="$3"
    local quantity="$4"
    local price="$5"
    local total="$6"
    local bucket="$7"
    local order_id="$8"
    local request_id="$9"
    local status="${10}"

    cat << EOF
---
id: FBA_$(date '+%Y-%m-%d')_${request_id}
timestamp: $(date -u '+%Y-%m-%dT%H:%M:%S%:z')
mode: ${mode}
bucket: ${bucket}
trade:
  action: ${action}
  symbol: ${symbol}
  quantity: ${quantity}
  price_per_share: ${price}
  total_value: ${total}
  currency: USD
$(generate_bucket_reasoning "$symbol")
alpaca:
  order_id: ${order_id}
  request_id: ${request_id}
  status: ${status}
archived_by: SET (@SetianWealth_Bot)
archived_at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')
---
EOF
}

write_trade_files() {
    local mode="$1"
    local action="$2"
    local symbol="$3"
    local quantity="$4"
    local price="$5"
    local total="$6"
    local bucket="$7"
    local order_id="$8"
    local request_id="$9"
    local status="${10}"

    local month=$(date '+%Y-%m')
    local timestamp=$(date '+%Y%m%d_%H%M%S')

    mkdir -p "${TRADE_DIR}/${month}"

    # 1. Write individual trade record
    local trade_file="${TRADE_DIR}/${month}/FBA_$(date '+%Y-%m-%d')_${request_id}.yaml"
    generate_trade_yaml "$mode" "$action" "$symbol" "$quantity" "$price" "$total" "$bucket" "$order_id" "$request_id" "$status" > "$trade_file"

    # 2. Update bucket positions.yaml
    update_bucket_positions "$bucket" "$symbol" "$quantity" "$price" "$total" "$action"

    # 3. Append to bucket history.yaml
    local trade_summary="| $(date '+%Y-%m-%d') | ${request_id} | ${action} | ${symbol} | \$${total} | ${status} |"
    append_bucket_history "$bucket" "$trade_summary"

    # 4. Write to Pending for Anpu detection
    local pending_file="${FBA_WEALTH_LOGS}/Pending/FBA_${timestamp}_${request_id}.pending"
    cp "$trade_file" "$pending_file"

    log_trading "INFO" "Trade files written: $trade_file, bucket=$bucket, pending=$pending_file"
}

# ============================================================
# RECONCILIATION FUNCTIONS
# ============================================================

sum_records_in_folder() {
    local folder="$1"
    local sum=0.0
    while IFS= read -r file; do
        local value=$(grep -F "total_value:" "$file" 2>/dev/null | awk '{print $2 || "0.00"}' | sed 's/,//g' | tr -d '$')
        if [[ -n "$value" ]] && [[ "$value" != "0.00" ]]; then
            sum=$(echo "$sum + $value" | bc -l)
        fi
    done < <(find "$folder" -name "*.yaml" -type f 2>/dev/null)
    printf "%.2f" "$sum"
}

sum_all_bucket_totals() {
    local sum=0.0
    for bucket in FOUNDATION GROWTH STORM; do
        local bucket_info=$(get_bucket_info "$bucket")
        local total=$(echo "$bucket_info" | cut -d: -f5)
        sum=$(echo "$sum + $total" | bc -l)
    done
    printf "%.2f" "$sum"
}

reconciliation_check() {
    local sum_trades=$(sum_records_in_folder "$TRADE_DIR")
    local sum_buckets=$(sum_all_bucket_totals)

    if (( $(echo "$sum_trades != $sum_buckets" | bc -l) )); then
        local diff=$(echo "$sum_trades - $sum_buckets" | bc -l | sed 's/^-//')
        log_trading "CRITICAL" "⚠️ RECONCILIATION MISMATCH: Records=\$$sum_trades, Buckets=\$$sum_buckets, Difference=\$$diff"
        send_set "⚠️ RECONCILIATION MISMATCH

Records total: \$${sum_trades}
Buckets total: \$${sum_buckets}
Difference: \$${diff}

IMMEDIATE ACTION REQUIRED:
1. Check bucket YAML files
2. Check trade records
3. Verify no data corruption

Guardian of Amenti
⚡"
        return 1
    fi

    log_trading "INFO" "✅ Reconciliation passed: Records=Buckets=\$$sum_trades"
    return 0
}

# ============================================================
# DAILY BUCKET SUMMARY GENERATION
# ============================================================

generate_daily_bucket_summary() {
    local date="$1"

    local summary_file="${FBA_WEALTH_LOGS}/Daily_Reports/Y2026/Bucket_Summary_${date}.md"
    mkdir -p "$(dirname "$summary_file")"

    local foundation_info=$(get_bucket_info "FOUNDATION")
    local growth_info=$(get_bucket_info "GROWTH")
    local storm_info=$(get_bucket_info "STORM")

    local foundation_total=$(echo "$foundation_info" | cut -d: -f5)
    local growth_total=$(echo "$growth_info" | cut -d: -f5)
    local storm_total=$(echo "$storm_info" | cut -d: -f5)
    local portfolio_total=$(echo "$foundation_total + $growth_total + $storm_total" | bc -l)

    local foundation_cash=$(echo "$foundation_info" | cut -d: -f3)
    local growth_cash=$(echo "$growth_info" | cut -d: -f3)
    local storm_cash=$(echo "$storm_info" | cut -d: -f3)

    cat > "$summary_file" << EOF
# Daily Bucket Summary - ${date}
**Generated:** $(date -u '+%Y-%m-%dT%H:%M:%SZ')
**Trading Mode:** ${TRADING_MODE}
**Guardian:** SET (@SetianWealth_Bot)

## Portfolio Overview

| Bucket | Current Value | Target % | Actual % | Cash Available | Seed Progress |
|--------|---------------|----------|----------|----------------|---------------|
| FOUNDATION | \$${foundation_total} | 50% | $(echo "scale=1; ($foundation_total / $portfolio_total) * 100" | bc)% | \$${foundation_cash} | $(echo "scale=2; ($foundation_total / 123.00) * 100" | bc)% |
| GROWTH | \$${growth_total} | 35% | $(echo "scale=1; ($growth_total / $portfolio_total) * 100" | bc)% | \$${growth_cash} | $(echo "scale=2; ($growth_total / 86.10) * 100" | bc)% |
| STORM | \$${storm_total} | 15% | $(echo "scale=1; ($storm_total / $portfolio_total) * 100" | bc)% | \$${storm_cash} | $(echo "scale=2; ($storm_total / 36.90) * 100" | bc)% |
| **TOTAL** | **\$$portfolio_total** | **100%** | **100%** | **\$$(echo "$foundation_cash + $growth_cash + $storm_cash" | bc)** | **$(echo "scale=2; ($portfolio_total / 246.00) * 100" | bc)%** |

## Holdings

### FOUNDATION
$(grep "last_trade:" "${BUCKETS_DIR}/FOUNDATION/positions.yaml" 2>/dev/null || echo "No trades yet")

### GROWTH
$(grep "last_trade:" "${BUCKETS_DIR}/GROWTH/positions.yaml" 2>/dev/null || echo "No trades yet")

### STORM
$(grep "last_trade:" "${BUCKETS_DIR}/STORM/positions.yaml" 2>/dev/null || echo "No trades yet")

## Allocation Check
$(if (( $(echo "$portfolio_total > 0" | bc -l) )); then
    if (( $(echo "$(echo "scale=1; ($foundation_total / $portfolio_total) * 100" | bc) > 52.5" | bc -l) )); then
        echo "⚠️ OVERFLOW: FOUNDATION exceeds 50% allocation"
    elif (( $(echo "$(echo "scale=1; ($growth_total / $portfolio_total) * 100" | bc) > 36.75" | bc -l) )); then
        echo "⚠️ OVERFLOW: GROWTH exceeds 35% allocation"
    elif (( $(echo "$(echo "scale=1; ($storm_total / $portfolio_total) * 100" | bc) > 15.75" | bc -l) )); then
        echo "⚠️ OVERFLOW: STORM exceeds 15% allocation"
    else
        echo "✅ All buckets within allocation targets (5% tolerance)"
    fi
else
    echo "No portfolio value to check allocations"
fi)

## Reconciliation Status
$(reconciliation_check && echo "✅ Records = Buckets" || echo "❌ Records ≠ Buckets - DATA MISMATCH DETECTED")

---
**SET (@SetianWealth_Bot)** — ⚡
EOF

    log_trading "INFO" "Generated daily bucket summary: $summary_file"
}

# ============================================================
# MAIN FUNCTIONS
# ============================================================

main() {
    local cmd="${1:-help}"

    case "$cmd" in
        check_overflow)
            local symbol="$2"
            local trade_value="$3"
            local action="${4:-BUY}"
            check_bucket_overflow "$symbol" "$trade_value" "$action"
            ;;
        write_trade)
            local action="$2"
            local symbol="$3"
            local quantity="$4"
            local price="$5"
            local bucket="$6"
            local order_id="$7"
            local request_id="$8"
            local status="${9:-FILLED}"

            local total=$(echo "$quantity * $price" | bc -l)

            # 1. Check bucket overflow before writing
            if ! check_bucket_overflow "$symbol" "$total" "$action"; then
                log_trading "ERROR" "Trade rejected: Bucket overflow"
                exit 1
            fi

            # 2. Write all trade files
            write_trade_files "$TRADING_MODE" "$action" "$symbol" "$quantity" "$price" "$total" "$bucket" "$order_id" "$request_id" "$status"

            # 3. Reconciliation check
            reconciliation_check

            # 4. Generate daily summary
            generate_daily_bucket_summary "$(date '+%Y-%m-%d')"
            ;;
        daily_summary)
            local date="${2:-$(date '+%Y-%m-%d')}"
            generate_daily_bucket_summary "$date"
            ;;
        reconcile)
            reconciliation_check
            ;;
        mode)
            echo "TRADING_MODE: $TRADING_MODE"
            echo "TRADE_DIR: $TRADE_DIR"
            echo "ALPACA_URL: $ALPACA_URL"
            ;;
        help|--help|-h)
            echo "🐊 SET Trade Filing System - Comprehensive"
            echo ""
            echo "Usage:"
            echo "  set-file-trades.sh mode                              # Show current mode"
            echo "  set-file-trades.sh check_overflow SYMBOL VALUE        # Check bucket overflow"
            echo "  set-file-trades.sh write_trade ACTION SYMBOL QTY PRICE BUCKET ORDER_ID REQUEST_ID"
            echo "  set-file-trades.sh daily_summary [DATE]              # Generate bucket summary"
            echo "  set-file-trades.sh reconcile                          # Check reconciliation"
            echo ""
            echo "Buckets: FOUNDATION (50%), GROWTH (35%), STORM (15%)"
            echo "Mode: $TRADING_MODE"
            echo "Guard: $TRADE_DIR"
            ;;
        *)
            echo "Unknown: $cmd"
            echo "Run 'set-file-trades.sh help'"
            exit 1
            ;;
    esac
}

# Execute
main "$@"