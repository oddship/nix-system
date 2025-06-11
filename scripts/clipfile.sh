#!/usr/bin/env bash

# clipfile.sh
# -----------
# Copy file contents to system clipboard with multiple backend support.
# Supports X11 (xclip, xsel), Wayland (wl-clipboard), and macOS (pbcopy).

set -euo pipefail

# Function: show_usage
# --------------------
# Display usage information and available options
show_usage() {
    cat << EOF
Usage: clipfile [OPTIONS] FILE

Copy the contents of a file to the system clipboard.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Show verbose output
    -n, --no-newline Remove trailing newline from output

EXAMPLES:
    clipfile file.txt
    clipfile -v ~/.ssh/id_rsa.pub
    clipfile -n config.json

SUPPORTED CLIPBOARD BACKENDS:
    - X11: xclip, xsel
    - Wayland: wl-copy (wl-clipboard)
    - macOS: pbcopy
EOF
}

# Function: detect_clipboard_backend
# ----------------------------------
# Detect available clipboard utility and return the command to use
detect_clipboard_backend() {
    local backend=""
    
    # Check for Wayland first (more modern)
    if command -v wl-copy >/dev/null 2>&1; then
        backend="wl-copy"
    # Check for X11 utilities
    elif command -v xclip >/dev/null 2>&1; then
        backend="xclip -selection clipboard"
    elif command -v xsel >/dev/null 2>&1; then
        backend="xsel --clipboard --input"
    # Check for macOS
    elif command -v pbcopy >/dev/null 2>&1; then
        backend="pbcopy"
    else
        echo "Error: No clipboard utility found." >&2
        echo "Please install one of: wl-clipboard, xclip, xsel, or ensure pbcopy is available." >&2
        exit 1
    fi
    
    echo "$backend"
}

# Function: copy_file_to_clipboard
# --------------------------------
# Copy file contents to clipboard using detected backend
copy_file_to_clipboard() {
    local file="$1"
    local backend="$2"
    local remove_newline="$3"
    local verbose="$4"
    
    # Validate file exists and is readable
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' does not exist or is not a regular file." >&2
        exit 1
    fi
    
    if [[ ! -r "$file" ]]; then
        echo "Error: File '$file' is not readable." >&2
        exit 1
    fi
    
    # Get file size for verbose output
    local file_size
    file_size=$(wc -c < "$file")
    
    if [[ "$verbose" == "true" ]]; then
        echo "File: $file"
        echo "Size: $file_size bytes"
        echo "Backend: $backend"
        echo "Copying to clipboard..."
    fi
    
    # Copy file contents to clipboard
    if [[ "$remove_newline" == "true" ]]; then
        # Remove trailing newline
        if ! tr -d '\n' < "$file" | eval "$backend"; then
            echo "Error: Failed to copy file contents to clipboard." >&2
            exit 1
        fi
    else
        # Keep original formatting
        if ! eval "$backend" < "$file"; then
            echo "Error: Failed to copy file contents to clipboard." >&2
            exit 1
        fi
    fi
    
    if [[ "$verbose" == "true" ]]; then
        echo "Successfully copied to clipboard!"
    else
        echo "Copied to clipboard: $file"
    fi
}

# Parse command line arguments
verbose="false"
remove_newline="false"
file=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -v|--verbose)
            verbose="true"
            shift
            ;;
        -n|--no-newline)
            remove_newline="true"
            shift
            ;;
        -*)
            echo "Error: Unknown option '$1'" >&2
            echo "Use --help for usage information." >&2
            exit 1
            ;;
        *)
            if [[ -n "$file" ]]; then
                echo "Error: Multiple files specified. Only one file allowed." >&2
                exit 1
            fi
            file="$1"
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$file" ]]; then
    echo "Error: No file specified." >&2
    echo "Use --help for usage information." >&2
    exit 1
fi

# Main execution
echo "=== Clipboard Copy Utility ===" >&2

# Detect clipboard backend
backend=$(detect_clipboard_backend)

if [[ "$verbose" == "true" ]]; then
    echo "Detected clipboard backend: $backend" >&2
fi

# Copy file to clipboard
copy_file_to_clipboard "$file" "$backend" "$remove_newline" "$verbose"