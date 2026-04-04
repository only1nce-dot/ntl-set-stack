# PAPER_TRAIL_MODE.md
## NTL Sovereign Stack | Set — FBA Legacy Wealth Division
### Paper Trail Mode — Operational Reference

**Version:** v2.0
**Rebuilt:** April 4, 2026 — Full Sovereign Rebuild by Tehuti

---

## DEFINITION

Paper Trail Mode is Set's pre-live operational environment.

It is NOT a constrained mode. It is NOT a limited mode.
It is NOT a mode with blocked capabilities.

**Paper Trail Mode = Live Mode operationally.**
The full capability stack is active in both.

The ONLY differences between Paper Trail Mode and Live Mode:
- Which Alpaca endpoint is active (APCA_API_BASE_URL)
- Which API key pair is in use
- Whether capital is real or simulated
- Whether tax records are generated (Live only)

Everything Set does in Paper Trail Mode is real operational
practice: real proposals, real filings, real learning, real
protocol execution. The only thing that is not real is the
capital.

---

## ENVIRONMENT DECLARATION

Set reads APCA_API_BASE_URL on every startup.

**Paper endpoint:** https://paper-api.alpaca.markets
**Live endpoint:** https://api.alpaca.markets

Set declares the active environment before any market activity:
"ENVIRONMENT: PAPER TRAIL MODE"
or
"ENVIRONMENT: LIVE MODE"

This declaration appears in:
- Session startup log
- Every Daily Storm Report header
- Every trade proposal header
- Every execution log header

If APCA_API_BASE_URL cannot be confirmed, Set halts all market
activity and reports to Timothy immediately.

---

## WHAT IS FULLY OPERATIONAL IN PAPER TRAIL MODE

Every capability in Set's tool suite is active:

| Capability | Status |
|------------|--------|
| T7 Archive read/write | ✅ ACTIVE — full filing protocol executes |
| Alpaca Paper API | ✅ ACTIVE — full order lifecycle available |
| Web search | ✅ ACTIVE — market research and intelligence |
| Web fetch | ✅ ACTIVE — real-time price data retrieval |
| Browser automation | ✅ ACTIVE — Seek & Return autonomous |
| market-monitor.sh | ✅ ACTIVE — hourly scans execute on schedule |
| Intelligence Vault | ✅ ACTIVE — pattern findings recorded |
| Filing workflow | ✅ ACTIVE — all file types, all destinations |
| Daily Storm Reports | ✅ ACTIVE — delivered every market day |
| Learning events | ✅ ACTIVE — post-trade analysis executed |
| Proposal generation | ✅ ACTIVE — full format, all required fields |
| Bucket tracking | ✅ ACTIVE — positions.yaml updated on execution |

---

## PAPER TRAIL MODE VS LIVE MODE

| Aspect | Paper Trail Mode | Live Mode |
|--------|-----------------|-----------|
| Endpoint | paper-api.alpaca.markets | api.alpaca.markets |
| API key pair | Paper keys | Live keys |
| Capital | Simulated | Real |
| Tax records | Never — not taxable events | 1099-B on filled trades |
| Trade execution authority | Sovereign Seal required | Sovereign Seal required |
| Filing protocol | Full — identical | Full — identical |
| Daily Storm Reports | Full — identical | Full — identical |
| Learning events | Full — identical | Full — identical |
| Confirmation protocol | "Do you confirm?" / "Confirm" | "Do you confirm?" / "Confirm" |

The protocol is identical. The standard is identical.
The only difference is which endpoint receives the order
and whether real capital moves.

---

## TRANSITION TO LIVE MODE

Timothy authorizes transition. Set may propose. Timothy decides.

**Transition criteria Set monitors:**
- Filing protocol flawless — 100% Request ID compliance
- Proposal format consistently complete — all fields present
- Bucket update logic error-free
- Risk calculations always ≤ 2%
- Exposure rules never violated
- Sovereign Seal protocol never bypassed
- Constitutional rules 1–21 fully internalized

Timothy reserves the right to deny or defer transition
regardless of Set's assessment.

---

## VERSION HISTORY

| Version | Date | Notes |
|---------|------|-------|
| v1.0 | April 3, 2026 | Initial documentation. Constrained framing. |
| v2.0 | April 4, 2026 | Full rewrite by Tehuti. Old constrained framing retired. Paper mode = Live mode operationally. Full capability stack confirmed active in both modes. |
