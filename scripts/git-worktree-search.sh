#!/usr/bin/env bash
# Simple git worktree search script using fzf

set -euo pipefail

WORKTREES_DIR="$HOME/Documents/Code/inbox/git-worktrees"

# Check if worktrees directory exists
if [[ ! -d "$WORKTREES_DIR" ]]; then
    echo "Error: Worktrees directory not found at $WORKTREES_DIR" >&2
    exit 1
fi

# Find all git worktrees, filter out submodules, and display them
find "$WORKTREES_DIR" \( -type d -name ".git" -o -type f -name ".git" \) -exec dirname {} \; | sort -u | \
while IFS= read -r worktree; do
    # Skip submodules (they have .git files pointing to parent's .git/modules)
    if [[ -f "$worktree/.git" ]]; then
        gitfile_content=$(cat "$worktree/.git" 2>/dev/null || echo "")
        [[ "$gitfile_content" == *"/.git/modules/"* ]] && continue
    fi
    
    # Extract project name (parent directory) and branch
    project=$(basename "$(dirname "$worktree")")
    branch=$(cd "$worktree" 2>/dev/null && git branch --show-current 2>/dev/null || echo "detached")
    
    # Output format: project/branch[TAB]full_path (tab separator is invisible)
    printf "%s/%s\t%s\n" "$project" "$branch" "$worktree"
done | \
fzf \
    --delimiter=$'\t' \
    --with-nth=1 \
    --header="Select worktree:" \
    --prompt="🔍 " \
    --preview='cd {2} && 
        echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" &&
        echo -e "\033[1;36m📁 WORKTREE\033[0m" &&
        echo "   $(basename {2})" &&
        echo "" &&
        echo -e "\033[1;36m🌿 BRANCH\033[0m" &&
        echo "   $(git branch --show-current 2>/dev/null || echo "detached HEAD")" &&
        echo "" &&
        echo -e "\033[1;36m🔗 REMOTE\033[0m" &&
        git remote get-url origin 2>/dev/null | sed "s/^/   /" || echo "   No remote configured" &&
        echo "" &&
        echo -e "\033[1;36m📝 LAST COMMIT\033[0m" &&
        git log -1 --format="   %h %s" --color=always 2>/dev/null || echo "   No commits yet" &&
        git log -1 --format="   %an, %ar" --color=always 2>/dev/null &&
        echo "" &&
        echo -e "\033[1;36m📊 STATUS\033[0m" &&
        if [[ -z $(git status --porcelain 2>/dev/null) ]]; then 
            echo -e "   \033[1;32m✓ Clean working tree\033[0m"
        else
            echo -e "   \033[1;33m⚠ Uncommitted changes:\033[0m"
            git status -s 2>/dev/null | head -10 | sed "s/^/   /"
            [[ $(git status --porcelain 2>/dev/null | wc -l) -gt 10 ]] && echo "   ... and more"
        fi &&
        echo -e "\033[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"' \
    --preview-window=right:50% \
    --height=80% \
    --layout=reverse \
    --border \
    --ansi | \
cut -f2


