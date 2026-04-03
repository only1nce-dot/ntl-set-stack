# SET Curated Autonomy Framework

**Version:** 1.0
**Constitutional Basis:** Rule 19 (Curated Autonomy)
**Created:** April 3, 2026
**Maintained by:** SET (@SetianWealth_Bot)
**Governed by:** Anpu (@AnpuAgent_Bot)
**Final Authority:** Timothy J. Cox (Sovereign Seal)

---

## 📜 Constitutional Framework

### Rule 19 — CURATED AUTONOMY

SET learns continuously from market feedback, but all strategy modifications require the Sovereign Seal's approval before deployment.

### The Learning Process (10 Steps):

1. **Trade executes** → SET records outcome
2. **SET analyzes** outcome against original hypothesis
3. **SET generates** hypothesis for improvement (autonomous)
4. **SET presents** hypothesis to Timothy (awaiting approval)
5. **Timothy approves/rejects/defers** hypothesis (guarded)
6. **IF approved:** SET generates code patch
7. **SET shows diff** to Timothy (awaiting code approval)
8. **IF approved:** SET runs backtests in paper mode
9. **SET presents** backtest results (awaiting deployment approval)
10. **IF improvement confirmed:** SET deploys to git, logs change, updates strategy

---

## 🤖 Autonomous Areas (No Approval Required)

- Market scanning and pattern detection
- Trade hypothesis generation
- Outcome analysis and lesson extraction
- Backtesting in paper mode
- Hypothesis submission to Timothy

---

## 🔐 Guarded Areas (Requires Sovereign Seal Approval)

- Code modifications to strategy files
- Parameter adjustments
- Strategy deployment to trading operations

---

## 🛡️ Guardrails

| Guardrail | Implementation |
|-----------|----------------|
| Git tracking | All changes version-controlled with instant rollback |
| Hard limits | Immutable caps: 2% risk, 3 positions, 40% capital |
| Paper validation | New strategies backtested before live deployment |
| Knowledge base | Every hypothesis logged (win or lose) |
| Three approvals | Hypothesis, code, deployment all need explicit approval |

---

## 📁 File Structure

```
~/.openclaw/workspaces/set/
├── learning/
│   ├── trade_journal.json          # All trade outcomes
│   ├── hypothesis_log.json         # All theories (pending, approved, rejected)
│   ├── mastery_log.json            # Confirmed improvements deployed
│   ├── rejected_hypotheses.json    # Discarded theories (valuable wisdom)
│   └── README.md                   # This file
├── strategy/
│   ├── set_strategy_v1.py          # Current trading brain (Python)
│   ├── patches/                    # Approved diffs
│   │   └── patch_000_template.py   # Template for new patches
│   └── .git/                       # Version control (repo)
└── backtests/
    └── [Results after execution]   # Backtest analysis results
```

---

## 🔄 Workflow Example

### Scenario: Loss on TSLA Trade

**Step 1: Autonomous Analysis** (SET)
```
Trade: TSLA BUY @ $245, Exit @ $230
Result: LOSS (-6.1%, 5 days)
Expected: +5-10% (2-7 days)

Root Cause: Volume threshold too low
Trade entered on 1.8x average volume (insufficient institutional confirmation)

Hypothesis: Increase volume threshold to 2.5x average + 3 bars stability
```

**Step 2: Hypothesis Presentation** (SET → Timothy)
```
🧠 LESSON LEARNED - TSLA Trade Loss
PROPOSED PARAMETER CHANGE:
Old: VOLUME_THRESHOLD = 1.5x
New: VOLUME_THRESHOLD = 2.5x

BACKTEST PREDICTION:
This change would have rejected 4 recent losing trades
and accepted 8 recent winning trades

Risk: May reduce trade frequency by ~35%
Reward: Expected win rate improvement: +8-12%

🔐 Awaiting your approval to proceed with code generation.
```

**Step 3-5: Code → Backtest → Deploy** (Three approvals)
1. Timothy: "APPROVE" → SET generates code patch
2. Timothy: "APPROVE CODE" → SET runs backtests
3. Timothy: "APPROVE DEPLOYMENT" → SET deploys to git

---

## 🧪 Python Strategy Engine

**Location:** `strategy/set_strategy_v1.py`

### Key Components:

#### 1. Constitutional Hard Limits (Immutable)
```python
class ConstitutionalLimits:
    MAX_RISK_PER_TRADE = 0.02      # 2% of total capital
    MAX_OPEN_POSITIONS = 3
    MAX_CAPITAL_DEPLOYED = 0.40    # 40% of total capital
    MIN_HOLD_DAYS = 2
    MAX_HOLD_DAYS = 30
    MIN_EXPECTED_MOVE = 0.03       # 3%
    MAX_EXPECTED_MOVE = 0.12       # 12%
```

#### 2. Configurable Parameters (Can be modified via Curated Autonomy)
```python
class StrategyParameters:
    VOLUME_THRESHOLD_MULTIPLIER = 2.5
    VOLUME_STABILITY_BARS = 3
    FOUR_HOUR_MOMENTUM_SHORT_MA = 4
    FOUR_HOUR_MOMENTUM_LONG_MA = 8
    DEFAULT_STOP_LOSS_ATR_MULTIPLIER = 1.5
    EXPERIMENT_NUMBER = 0  # Increments with each approved change
```

#### 3. Pattern Recognition Functions
- `detect_bullish_engulfing_pattern()` - Daily chart reversal detection
- `detect_four_hour_momentum()` - 4H MA crossover analysis
- `calculate_risk_percentage()` - Enforces constitutional limits
- `calculate_position_size()` - Risk-based position sizing

#### 4. Learning System (Autonomous)
```python
class LearningSystem:
    @staticmethod
    def analyze_trade_outcome(...) -> Hypothesis:
        """Analyze closed trade and generate improvement hypothesis"""
        # This is AUTONOMOUS - analysis happens without approval
        # The hypothesis itself still needs approval before code changes
```

---

## 🧩 Data Structures

### TradeProposal
```python
@dataclass
class TradeProposal:
    symbol: str
    action: str  # 'BUY' or 'SELL'
    entry_zone: tuple  # (low, high)
    target: float
    expected_move: float  # percentage
    stop_loss: float
    risk_percentage: float  # Must be <= 2%
    bucket: str  # 'FOUNDATION', 'GROWTH', 'STORM'
    conviction: str  # 'High' or 'Medium'
    # ... and more
```

### Hypothesis
```python
@dataclass
class Hypothesis:
    hypothesis_id: str
    trade_id: str
    root_cause_theory: str
    proposed_change: str
    backtest_prediction: str
    status: str  # 'Pending Approval', 'Approved', 'Rejected', 'Deferred'
    # ... and more
```

---

## 📊 Learning Data Files

### 1. trade_journal.json
```json
{
  "journal": [
    {
      "trade_id": "TSLA-2026-04-03-001",
      "entry": 245.00,
      "exit": 230.00,
      "result": "LOSS",
      "pct_change": -6.1,
      "duration_days": 5,
      "bucket": "STORM",
      "timestamp": "2026-04-03T15:30:00Z"
    }
  ]
}
```

### 2. hypothesis_log.json
```json
{
  "hypotheses": [
    {
      "hypothesis_id": "HYP-20260403003042",
      "trade_id": "TSLA-2026-04-03-001",
      "root_cause_theory": "Volume threshold too low",
      "proposed_change": "VOLUME_THRESHOLD: 1.5x → 2.5x",
      "status": "Approved",
      "approved_by": "Timothy"
    }
  ]
}
```

### 3. mastery_log.json
```json
{
  "mastery": [
    {
      "experiment_number": 1,
      "patch_id": "PATCH_001",
      "hypothesis_id": "HYP-20260403003042",
      "change_summary": "Volume threshold increased",
      "improvement": "+8.1% win rate, +2.5% return",
      "deployed_at": "2026-04-03T16:30:00Z"
    }
  ]
}
```

### 4. rejected_hypotheses.json
```json
{
  "rejected": [
    {
      "hypothesis_id": "HYP-20260402120000",
      "proposed_change": "Increase stop loss to 2.0x ATR",
      "status": "Rejected",
      "note": "Too risky - increases maximum loss potential"
    }
  ]
}
```

---

## 🚀 Initialization Commands

### Git Repository Setup
```bash
cd ~/.openclaw/workspaces/set
./init_strategy_repo.sh
```

### Demonstrate Learning Workflow
```bash
cd ~/.openclaw/workspaces/set
python3 demonstrate_learning_workflow.py
```

### Test Strategy Engine
```bash
cd ~/.openclaw/workspaces/set/strategy
python3 set_strategy_v1.py
```

---

## 🔧 Patch Naming Convention

`patch_XXX_description.py`

Examples:
- `patch_001_volume_threshold_adjust.py`
- `patch_002_volatility_filter.py`
- `patch_003_earnings_buffer.py`
- `patch_004_momentum_confirmation.py`

---

## 📋 Approval Checklist

Before allowing any code modification:

- [ ] Hypothesis approved by Timothy
- [ ] Code patch generated and reviewed
- [ ] Backtest completed in paper mode
- [ ] Backtest shows improvement
- [ ] Git commit with descriptive message
- [ ] Anpu notified of deployment event

---

## ⚡ Key Principles

1. **Autonomy in Analysis** - SET generates hypotheses without interference
2. **Authority in Execution** - Timothy approves all code changes
3. **Transparency in Tracking** - Git logs every change
4. **Safety in Validation** - Paper trading before live capital
5. **Wisdom in Learning** - Even rejected hypotheses are logged (knowledge)

---

## 🐺 Governance

SET operates under Anpu's governance (Rule 19 additions). All learning events are logged to the T7 Archive for Anpu's monitoring.

Anpu responsibilities:
- Monitor all hypothesis submissions
- Track deployment events
- Verify learning system integrity
- Alert Timothy to anomalies
- Maintain historical learning records

---

**Result:** SET continuously improves while honoring the Sovereign Seal's absolute authority. Order emerges from chaos through curated, guarded learning.

⚡