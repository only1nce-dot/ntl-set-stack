#!/bin/bash
# init_strategy_repo.sh - Initialize git repository for SET's strategy code
# Part of Curated Autonomy infrastructure (Rule 19)

set -euo pipefail

STRATEGY_DIR="${HOME}/.openclaw/workspaces/set/strategy"

cd "$STRATEGY_DIR"

# Initialize git repo if not already initialized
if [[ ! -d ".git" ]]; then
    echo "🔧 Initializing git repository for SET strategy..."
    git init
    git add .
    git commit -m "⚡ SET Strategy Engine v1.0 - Initial Commit

- Curated Autonomy Framework (Rule 19)
- Constitutional Hard Limits (immutable)
- Pattern Recognition Engine
- Hypothesis Generation System
- Guardrails: 2% max risk, 3 max positions, 40% max capital
- Patch system for controlled modifications
- Rollback capability enabled

Maintained by: SET (@SetianWealth_Bot)
Governed by: Anpu (@AnpuAgent_Bot)
Final Authority: Timothy J. Cox (Sovereign Seal)"
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Show current status
echo ""
echo "📋 Current Git Status:"
git status

echo ""
echo "🔍 Recent Commits:"
git log --oneline -5 2>/dev/null || echo "No commits yet"

echo ""
echo "⚡ SET Strategy Repository Ready"
echo "Rollback command: git revert <commit-hash>"