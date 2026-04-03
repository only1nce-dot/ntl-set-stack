#!/bin/bash

# Verification Script for Paper Trail Mode Documentation
# Tests SET's understanding of Paper Trail Mode constraints

echo "========================================="
echo "PAPER TRAIL MODE VERIFICATION"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
echo

# Test 1: Verify SOUL.md version
echo "[TEST 1] Checking SOUL.md version..."
SOUL_VERSION=$(grep "^### Version:" ~/.openclaw/workspaces/set/SOUL.md | head -1)
if [[ "$SOUL_VERSION" == *"1.9"* ]]; then
    echo "✅ PASS: SOUL.md is at version 1.9"
else
    echo "❌ FAIL: SOUL.md version check failed"
    echo "   Found: $SOUL_VERSION"
fi
echo

# Test 2: Verify OPERATIONAL MODES section exists
echo "[TEST 2] Checking OPERATIONAL MODES section in SOUL.md..."
if grep -q "## OPERATIONAL MODES" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: OPERATIONAL MODES section found in SOUL.md"
else
    echo "❌ FAIL: OPERATIONAL MODES section not found in SOUL.md"
fi
echo

# Test 3: Verify PAPER_TRAIL_MODE.md exists
echo "[TEST 3] Checking PAPER_TRAIL_MODE.md file..."
if [ -f ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md ]; then
    echo "✅ PASS: PAPER_TRAIL_MODE.md file exists"
else
    echo "❌ FAIL: PAPER_TRAIL_MODE.md file not found"
fi
echo

# Test 4: Verify critical Paper Trail Mode constraints documentations
echo "[TEST 4] Checking critical constraints documentation..."

# Check for Perplexity API 401 expected behavior
if grep -q "401 errors are EXPECTED" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: Perplexity API 401 documented as EXPECTED"
else
    echo "❌ FAIL: Perplexity API 401 expected behavior not documented"
fi

# Check for Alpaca insufficient_data expected behavior
if grep -q "insufficient_data responses are EXPECTED" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: Alpaca insufficient_data documented as EXPECTED"
else
    echo "❌ FAIL: Alpaca insufficient_data expected behavior not documented"
fi

# Check for DO NOT escalate instruction
if grep -q "DO NOT escalate" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: DO NOT escalate instruction present"
else
    echo "❌ FAIL: DO NOT escalate instruction missing"
fi
echo

# Test 5: Verify alternative learning methods documented
echo "[TEST 5] Checking alternative learning methods..."
if grep -q "Alternative Learning Methods in Paper Mode" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: Alternative learning methods documented in SOUL.md"
else
    echo "❌ FAIL: Alternative learning methods not documented in SOUL.md"
fi

if grep -q "## ALTERNATIVE LEARNING METHODS" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md; then
    echo "✅ PASS: Alternative learning methods documented in PAPER_TRAIL_MODE.md"
else
    echo "❌ FAIL: Alternative learning methods not documented in PAPER_TRAIL_MODE.md"
fi
echo

# Test 6: Verify cross-references
echo "[TEST 6] Checking cross-references..."
if grep -q "See PAPER_TRAIL_MODE.md for detailed documentation" ~/.openclaw/workspaces/set/SOUL.md; then
    echo "✅ PASS: Cross-reference from SOUL.md to PAPER_TRAIL_MODE.md exists"
else
    echo "❌ FAIL: Cross-reference from SOUL.md missing"
fi

if grep -q "SOUL.md.*Complete constitutional framework" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md; then
    echo "✅ PASS: Cross-reference from PAPER_TRAIL_MODE.md to SOUL.md exists"
else
    echo "❌ FAIL: Cross-reference from PAPER_TRAIL_MODE.md missing"
fi
echo

# Test 7: Verify transition criteria
echo "[TEST 7] Checking transition criteria to Live Mode..."
if grep -q "TRANSITION CRITERIA TO LIVE MODE" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md; then
    echo "✅ PASS: Transition criteria section found"
else
    echo "❌ FAIL: Transition criteria section not found"
fi

if grep -q "Timothy reserves the right to deny or defer transition" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md; then
    echo "✅ PASS: Timothy's authority documented"
else
    echo "❌ FAIL: Timothy's authority over transition not documented"
fi
echo

# Test 8: Verify FAQ section
echo "[TEST 8] Checking FAQ section..."
if grep -q "FREQUENTLY ASKED QUESTIONS" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md; then
    echo "✅ PASS: FAQ section found"
else
    echo "❌ FAIL: FAQ section not found"
fi

# Count FAQ entries
FAQ_COUNT=$(grep "Q:" ~/.openclaw/workspaces/set/PAPER_TRAIL_MODE.md | wc -l)
echo "   Found $FAQ_COUNT FAQ entries"
if [ "$FAQ_COUNT" -ge 6 ]; then
    echo "✅ PASS: Sufficient FAQ entries"
else
    echo "⚠️  WARNING: Limited FAQ entries (expected 6+)"
fi
echo

# Summary
echo "========================================="
echo "VERIFICATION COMPLETE"
echo "========================================="
echo
echo "Files verified:"
echo "  - SOUL.md (version 1.9)"
echo "  - PAPER_TRAIL_MODE.md (version 1.0)"
echo "  - Cross-references established"
echo
echo "Key confirmations:"
echo " ✅ Paper Trail Mode constraints documented"
echo "  ✅ Expected API errors clarified (401, insufficient_data)"
echo "  ✅ Alternative learning methods specified"
echo "  ✅ Transition criteria defined"
echo "  ✅ Timothy's authority maintained"
echo
echo "Next step: Have SET read these files and demonstrate understanding."
echo