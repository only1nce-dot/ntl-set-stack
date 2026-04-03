# SET Market Monitor — Sample Alert Reference

**Purpose:** This file shows exactly what you'll receive from SET's market monitor.

**Channel:** @SetianWealth_Bot (SET - Strategic Swing Trader)  
**Frequency:** Hourly (9AM-5PM CST, Mon-Fri)  
**Trigger:** When "POTENTIAL SETUP" detected in logs

---

## 📋 SAMPLE ALERT FORMAT

═══════════════════════════════════════════════════════════════
  🚨 SET MARKET MONITOR — POTENTIAL SETUP
═══════════════════════════════════════════════════════════════

📊 Asset: NVDA (NVIDIA Corporation)
⏰ Detected: 2026-04-03 09:00:00 CST
🎯 Pattern: Bullish Flag Breakout (4H timeframe)

───────────────────────────────────────────────────────────────────

📈 ANALYSIS SUMMARY

Current Price: $874.52
Pattern Type: Bull Flag Flag
Breakout Level: $870.00
Volume Surge: +234% above average
RSI (14): 62.4 (bullish momentum)
MACD: Signal crossover (buy signal)

───────────────────────────────────────────────────────────────────

💼 BUCKET RECOMMENDATION

🌱 GROWTH Bucket
→ Position Size: $1,260 (15% of bucket)
→ Max Risk: 2% of portfolio
→ Stop Loss: $830.00 (-5.1%)
→ Target: $920.00 (+5.3%)

Risk-to-Reward: 1:1.04

───────────────────────────────────────────────────────────────────

<reasoning>
Delta: 0.85 (high directional sensitivity)
Volatility Index: 68 (elevated but manageable)
Risk-to-Reward: 1:1.04 (favorable setup)

Trade Rationale:
NVDA showing high-volume breakout from bullish flag pattern. 
4H chart confirms structure with clear breakout level. 
Volume surge confirms institutional participation. 
RSI showing room to run. 
Stop loss placed below flag support. 
Target at recent resistance level.

Constraints Check:
- Max position size: ✅ 15% of bucket (within 15% limit)
- Max deployed capital: ✅ Will be 48% (within 40% limit)
- Max active positions: ⚠️ Will be position #1 (within 3 limit)
- Global stop loss: ✅ -5.1% < -10% threshold
- Pre-flight audit: ⚠️ Requires execution
</reasoning>

───────────────────────────────────────────────────────────────────

⚡ ACTION REQUIRED

SET has identified a POTENTIAL SETUP.

Timothy, please review and confirm if you want SET to execute:

1. Analyze deeper with full technical indicators
2. Propose additional confirmation signals
3. Draft trade order with limit price
4. Wait for your EXECUTE command

───────────────────────────────────────────────────────────────────

🆘 INFRASTRUCTURE STATUS

✅ T7 Archive: Mounted (1.8Ti free)
✅ Buckets: Aligned (Foundation 50%, Growth 35%, Storm 15%)
✅ Pre-Flight: Ready (pending execution)
✅ Mode: PAPER TRADING

───────────────────────────────────────────────────────────────────

To acknowledge: "SET, acknowledged"
To analyze deeper: "SET, analyze NVDA"
To skip setup: "SET, skip NVDA"

═══════════════════════════════════════════════════════════════
  SET AI Trading Agent • deepseek-v3.2:cloud • PAPER MODE
═══════════════════════════════════════════════════════════════

---

## 📊 KEY COMPONENTS EXPLAINED

### Alert Header
- 📊 **Asset:** Ticker symbol and company name
- ⏰ **Detected:** Timestamp when setup found
- 🎯 **Pattern:** Trading setup type or pattern detection

### Analysis Summary
- **Current Price:** Last known price
- **Pattern Type:** Technical pattern identified
- **Breakout Level:** Key resistance/support level
- **Volume Surge:** Volume percentage above average
- **RSI (14):** Relative Strength Index (momentum)
- **MACD:** Moving Average Convergence Divergence

### Bucket Recommendation
- **Bucket:** FOUNDATION / GROWTH / STORM
- **Position Size:** Dollar amount to enter
- **Max Risk:** Percentage of portfolio at risk
- **Stop Loss:** Exit point if trade goes wrong
- **Target:** Profit target
- **Risk-to-Reward:** Ratio of potential gain to risk

### <reasoning> Block
**REQUIRED:** Every trade proposal includes this block with:
- **Delta:** Price sensitivity (-1 to +1)
- **Volatility Index:** Current volatility level
- **Risk-to-Reward:** Numeric ratio
- **Trade Rationale:** Why this setup makes sense
- **Constraints Check:** Verification of risk limits

### Action Required
SET does NOT execute automatically. Options:
1. Analyze deeper
2. Propose additional signals
3. Draft order
4. Wait for EXECUTE command

### Infrastructure Status
Quick health check of system components

### Response Options
Quick commands to respond to SET
- `"SET, acknowledged"` - Mark as reviewed
- `"SET, analyze NVDA"` - Get deeper analysis
- `"SET, skip NVDA"` - Skip this setup

---

## 📅 WHEN YOU'LL RECEIVE ALERTS

| Time (CST) | Trigger | Frequency |
|------------|---------|-----------|
| 9:00 AM | Market opens, hourly scan | Hourly |
| 10:00 AM | Scan for setups | Hourly |
| 11:00 AM | Scan for setups | Hourly |
| 12:00 PM | Scan for setups | Hourly |
| 1:00 PM | Scan for setups | Hourly |
| 2:00 PM | Scan for setups | Hourly |
| 3:00 PM | Scan for setups | Hourly |
| 4:00 PM | Scan for setups | Hourly |
| 5:00 PM | Final scan before close | Hourly |

**Days:** Monday - Friday (no weekends)

**Log Location:** `/tmp/set-cron.log`

**Script Location:** `/Users/timothycox/.openclaw/scripts/set-market-monitor.sh`

---

## 🚨 SCENARIOS

### Scenario 1: No Setup Found
**Result:** No alert sent. Silence means nothing detected.

### Scenario 2: Single Setup Found
**Result:** One alert with the setup details.

### Scenario 3: Multiple Setups Found
**Result:** Multiple alerts, one per setup.

### Scenario 4: Infrastructure Issue
**Result:** Anpu (@AnpuAgent_Bot) alerts about the issue. SET does not report infrastructure problems.

---

## 💡 TIPS FOR RESPONDING

### Quick Response
```
SET, acknowledged
```
Mark as reviewed but don't act now.

### Deep Analysis Request
```
SET, analyze NVDA with RSI, MACD, BB, volume
```
Get deeper technical analysis with specific indicators.

### Skip Setup
```
SET, skip NVDA
```
Don't proceed with this setup.

### Request Trade Proposal
```
SET, propose trade for NVDA $1260 limit 870
```
Have SET draft the actual trade order.

---

## 🎯 CHANNEL REMINDER

| Channel | Agent | Purpose |
|---------|-------|---------|
| **@SetianWealth_Bot** | SET | Market setups, trade proposals |
| **@AnpuAgent_Bot** | Anpu | Infrastructure, system alerts |
| **@B4I87I86_Bot** | Genie | Operations, business |

**SET's alerts ONLY come from @SetianWealth_Bot**

---

**Document Created:** April 3, 2026  
**Reference:** Sample alert format explained  
**Status:** ✅ READY FOR REVIEW

---

**Next Market Monitor Run:** 9:00 AM CST (today)
**Channel:** @SetianWealth_Bot
**Mode:** PAPER TRADING