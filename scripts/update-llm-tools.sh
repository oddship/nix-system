#!/usr/bin/env bash

# update-llm-tools.sh
# -------------------
# Updates Node.js LLM CLI tools to latest versions

set -euo pipefail

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# List of LLM tools to update
tools=(
    "@anthropic-ai/claude-code"
    "@google/gemini-cli"
    "@sourcegraph/amp"
    "@openai/codex"
    "opencode-ai"
)

# Capture old versions before updating
echo -e "${BLUE}Capturing current versions...${NC}"
declare -A old_versions
for tool in "${tools[@]}"; do
    old_versions["$tool"]=$(npm list -g "$tool" --depth=0 2>/dev/null | grep "$tool" | sed 's/.*@//' || echo "not installed")
done

echo -e "${BLUE}Updating Node.js LLM CLI tools...${NC}"

# Update each tool
for tool in "${tools[@]}"; do
    echo -e "${YELLOW}Updating ${tool}...${NC}"
    npm update -g "$tool"
done

echo -e "${GREEN}All LLM tools updated successfully!${NC}"

# Show version comparison
echo -e "${BLUE}Version updates:${NC}"
for tool in "${tools[@]}"; do
    old_version="${old_versions[$tool]}"
    new_version=$(npm list -g "$tool" --depth=0 2>/dev/null | grep "$tool" | sed 's/.*@//' || echo "not installed")

    if [ "$old_version" = "$new_version" ]; then
        echo -e "  ${tool}: ${CYAN}${old_version}${NC} (no change)"
    else
        echo -e "  ${tool}: ${CYAN}${old_version}${NC} → ${GREEN}${new_version}${NC}"
    fi
done
