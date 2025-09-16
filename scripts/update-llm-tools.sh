#!/usr/bin/env bash

# update-llm-tools.sh
# -------------------
# Updates Node.js LLM CLI tools to latest versions

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Updating Node.js LLM CLI tools...${NC}"

# List of LLM tools to update
tools=(
    "@anthropic-ai/claude-code"
    "@google/gemini-cli" 
    "@sourcegraph/amp"
    "@openai/codex"
)

# Update each tool
for tool in "${tools[@]}"; do
    echo -e "${YELLOW}Updating ${tool}...${NC}"
    npm update -g "$tool"
done

echo -e "${GREEN}All LLM tools updated successfully!${NC}"

# Show current versions
echo -e "${BLUE}Current versions:${NC}"
for tool in "${tools[@]}"; do
    version=$(npm list -g "$tool" --depth=0 2>/dev/null | grep "$tool" | sed 's/.*@//' || echo "not installed")
    echo "  $tool: $version"
done
