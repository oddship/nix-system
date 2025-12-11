#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PORT=9222
MCP_FILE=".mcp.json"

# Check if Chromium is running with remote debugging
if ! curl -s "http://127.0.0.1:$PORT/json/version" > /dev/null 2>&1; then
    echo -e "${YELLOW}Chromium not running with remote debugging. Starting...${NC}"
    chromium --remote-debugging-port=$PORT &
    sleep 2  # Wait for startup
fi

# Get websocket endpoint
WS_URL=$(curl -s "http://127.0.0.1:$PORT/json/version" | jq -r '.webSocketDebuggerUrl')

if [ -z "$WS_URL" ] || [ "$WS_URL" = "null" ]; then
    echo -e "${RED}Failed to get websocket endpoint${NC}"
    exit 1
fi

echo -e "${GREEN}Got websocket endpoint: $WS_URL${NC}"

# MCP server config
CHROME_MCP=$(jq -n --arg ws "$WS_URL" '{
  "command": "npx",
  "args": ["-y", "chrome-devtools-mcp@latest", "--wsEndpoint", $ws]
}')

# Update or create .mcp.json
if [ -f "$MCP_FILE" ]; then
    # File exists - update or add chrome-devtools
    jq --argjson mcp "$CHROME_MCP" '.mcpServers["chrome-devtools"] = $mcp' "$MCP_FILE" > "$MCP_FILE.tmp"
    mv "$MCP_FILE.tmp" "$MCP_FILE"
    echo -e "${GREEN}Updated $MCP_FILE${NC}"
else
    # Create new file
    jq -n --argjson mcp "$CHROME_MCP" '{"mcpServers": {"chrome-devtools": $mcp}}' > "$MCP_FILE"
    echo -e "${GREEN}Created $MCP_FILE${NC}"
fi

echo -e "${GREEN}Done!${NC}"
