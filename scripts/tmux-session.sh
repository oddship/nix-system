#!/usr/bin/env bash

# tmux-session.sh
# ---------------
# Interactive tmux session manager using fzf

set -euo pipefail

# Function to create a new session
create_session() {
    local session_name="$1"
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Session '$session_name' already exists!"
        return 1
    fi
    
    tmux new-session -d -s "$session_name"
    echo "Created session: $session_name"
}

# Function to create a development session for current directory
create_dev_session() {
    local session_name
    session_name=$(basename "$PWD")
    
    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Development session '$session_name' already exists!"
        tmux attach-session -t "$session_name"
        return 0
    fi
    
    echo "Creating development session: $session_name"
    
    # Create session with editor
    tmux new-session -d -s "$session_name" -c "$PWD"
    
    # Send nvim to the first pane
    tmux send-keys -t "$session_name" "nvim" C-m
    
    # Split horizontally for terminal
    tmux split-window -t "$session_name" -h -c "$PWD"
    
    # Split the right pane vertically for commands
    tmux split-window -t "$session_name" -v -c "$PWD"
    
    # Attach to the session
    tmux attach-session -t "$session_name"
}

# Function to list sessions with fzf
list_sessions() {
    local sessions
    sessions=$(tmux ls 2>/dev/null | cut -d: -f1)
    
    if [ -z "$sessions" ]; then
        echo "No tmux sessions found"
        return 1
    fi
    
    echo "$sessions"
}

# Function to select and attach to session
attach_session() {
    local session
    session=$(list_sessions | fzf --prompt="Select session: " --height=40% --border)
    
    if [ -n "$session" ]; then
        tmux attach-session -t "$session"
    fi
}

# Function to kill session
kill_session() {
    local session
    session=$(list_sessions | fzf --prompt="Kill session: " --height=40% --border)
    
    if [ -n "$session" ]; then
        if [ "$session" = "$(tmux display-message -p '#S')" ]; then
            echo "Cannot kill current session from within tmux"
            return 1
        fi
        
        tmux kill-session -t "$session"
        echo "Killed session: $session"
    fi
}

# Function to show session info
show_session_info() {
    local session
    session=$(list_sessions | fzf --prompt="Show info for session: " --height=40% --border)
    
    if [ -n "$session" ]; then
        echo "Session: $session"
        tmux list-windows -t "$session" -F "#{window_index}: #{window_name} (#{window_panes} panes)"
    fi
}

# Main menu
show_menu() {
    local choice
    choice=$(cat <<EOF | fzf --prompt="Tmux Session Manager: " --height=40% --border
Attach to existing session
Create new session
Create development session (current dir)
Kill session
Show session info
List all sessions
EOF
)
    
    case "$choice" in
        "Attach to existing session")
            attach_session
            ;;
        "Create new session")
            read -p "Enter session name: " session_name
            if [ -n "$session_name" ]; then
                create_session "$session_name"
                tmux attach-session -t "$session_name"
            fi
            ;;
        "Create development session (current dir)")
            create_dev_session
            ;;
        "Kill session")
            kill_session
            ;;
        "Show session info")
            show_session_info
            ;;
        "List all sessions")
            if ! list_sessions; then
                echo "No sessions found"
            fi
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

# Parse command line arguments
case "${1:-}" in
    "-h"|"--help")
        cat <<EOF
Usage: $0 [OPTIONS]

Interactive tmux session manager

OPTIONS:
    -h, --help          Show this help message
    -l, --list          List all sessions
    -a, --attach        Attach to session (with fzf selection)
    -c, --create NAME   Create new session
    -k, --kill          Kill session (with fzf selection)
    -d, --dev           Create development session for current directory
    -i, --info          Show session info

Without arguments, shows interactive menu.
EOF
        ;;
    "-l"|"--list")
        list_sessions || echo "No sessions found"
        ;;
    "-a"|"--attach")
        attach_session
        ;;
    "-c"|"--create")
        if [ -z "${2:-}" ]; then
            echo "Error: Session name required"
            exit 1
        fi
        create_session "$2"
        tmux attach-session -t "$2"
        ;;
    "-k"|"--kill")
        kill_session
        ;;
    "-d"|"--dev")
        create_dev_session
        ;;
    "-i"|"--info")
        show_session_info
        ;;
    "")
        show_menu
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use -h or --help for usage information"
        exit 1
        ;;
esac