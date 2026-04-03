#!/bin/bash
# init-intelligence-vault.sh - Initialize Intelligence Vault with proper JSON structure

set -euo pipefail

VAULT_DIR="/Volumes/T7_Archive/FBA_Wealth_Logs/Intelligence/Assets"

# Create vault directory if it doesn't exist
mkdir -p "$VAULT_DIR"

# Read sacred assets
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SACRED_ASSETS_FILE="${SCRIPT_DIR}/sacred_assets.json"

if [[ ! -f "$SACRED_ASSETS_FILE" ]]; then
    echo "Error: Sacred assets file not found: $SACRED_ASSETS_FILE"
    exit 1
fi

# Get all assets
assets=($(jq -r '.all_assets[]' "$SACRED_ASSETS_FILE"))

echo "Initializing Intelligence Vault for ${#assets[@]} Sacred Assets..."

# Initialize each asset file with proper JSON structure
for symbol in "${assets[@]}"; do
    vault_file="${VAULT_DIR}/${symbol}.json"
    
    # Create initial JSON structure if file doesn't exist or is empty/corrupted
    if [[ ! -f "$vault_file" ]] || [[ ! -s "$vault_file" ]] || ! jq empty "$vault_file" >/dev/null 2>&1; then
        echo "{\n  \"asset\": \"${symbol}\",\n  \"pattern_findings\": [],\n  \"last_scan\": null\n}" > "$vault_file"
        echo "Created $vault_file"
    else
        echo "Valid file already exists: $vault_file"
    fi
done

echo "Intelligence Vault initialization complete!"
echo "Vault location: $VAULT_DIR"