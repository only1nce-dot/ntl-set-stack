#!/bin/bash
# Execute market territory scan and capture output

cd /Users/timothycox/.openclaw/workspaces/set

# Check if script is executable
if [[ ! -x "market-monitor.sh" ]]; then
    chmod +x market-monitor.sh
fi

# Try to load environment if exists
ENV_FILE="${HOME}/.openclaw/.env"
if [[ -f "$ENV_FILE" ]]; then
    echo "Loading environment from $ENV_FILE..."
    export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

echo "Executing market territory scan..."
echo "Command: ./market-monitor.sh territory"
echo ""

# Execute the scan with timeout to prevent hanging
./market-monitor.sh territory 2>&1 | tee scan_output.txt

echo ""
echo "Scan complete. Output saved to scan_output.txt"