#!/usr/bin/env bash

# mdview.sh - Render markdown file and open in browser
# Usage: mdview.sh <markdown-file>

# Exit on error
set -e

# Check if pandoc is available
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is required but not installed"
    exit 1
fi

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Error: No markdown file specified"
    echo "Usage: mdview.sh <markdown-file>"
    exit 1
fi

MARKDOWN_FILE="$1"

# Check if file exists
if [ ! -f "$MARKDOWN_FILE" ]; then
    echo "Error: File '$MARKDOWN_FILE' does not exist"
    exit 1
fi

# Create temporary HTML file
TEMP_HTML=$(mktemp --suffix=.html)

# Convert markdown to HTML with GitHub-style CSS
pandoc "$MARKDOWN_FILE" -o "$TEMP_HTML" --standalone --css="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-light.min.css" --metadata title="$(basename "$MARKDOWN_FILE")"

# Add wrapper div for GitHub markdown styling
sed -i 's/<body>/<body><div class="markdown-body" style="box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px;">/' "$TEMP_HTML"
sed -i 's/<\/body>/<\/div><\/body>/' "$TEMP_HTML"

echo "Rendered markdown to: $TEMP_HTML"

# Open in default browser
if command -v xdg-open &> /dev/null; then
    xdg-open "$TEMP_HTML"
elif command -v open &> /dev/null; then
    open "$TEMP_HTML"
else
    echo "Could not detect browser opener. Please open: $TEMP_HTML"
fi