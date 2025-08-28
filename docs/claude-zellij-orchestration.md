# Zellij Development Environment Setup

A practical guide for using Zellij to create structured development sessions with Claude Code.

## Basic Zellij Control

### Session Management
```bash
# Create detached session
zellij -d -s session-name

# List sessions
zellij ls

# Kill session
zellij kill-session session-name

# Send commands to specific session
ZELLIJ_SESSION_NAME=session-name zellij action write-chars "command"
ZELLIJ_SESSION_NAME=session-name zellij action write 13  # Enter key
```

## Development Environment Setup

### Multi-Pane Development Session
```bash
# Create main development session
zellij -d -s dev

# Pane 1: Claude Code
ZELLIJ_SESSION_NAME=dev zellij action write-chars "claude"
ZELLIJ_SESSION_NAME=dev zellij action write 13

# Pane 2: Development server
ZELLIJ_SESSION_NAME=dev zellij action new-pane
ZELLIJ_SESSION_NAME=dev zellij action write-chars "npm run dev"
ZELLIJ_SESSION_NAME=dev zellij action write 13

# Pane 3: Test watcher
ZELLIJ_SESSION_NAME=dev zellij action new-pane
ZELLIJ_SESSION_NAME=dev zellij action write-chars "npm run test:watch"
ZELLIJ_SESSION_NAME=dev zellij action write 13
```

### Project-Specific Sessions
```bash
# Frontend development
zellij -d -s frontend
ZELLIJ_SESSION_NAME=frontend zellij action write-chars "cd /path/to/frontend && claude"

# Backend development
zellij -d -s backend
ZELLIJ_SESSION_NAME=backend zellij action write-chars "cd /path/to/backend && claude"
```

## Automation Scripts

### Development Environment Bootstrap
```bash
setup_dev_environment() {
    local project_name=$1
    local project_path=$2
    
    # Create session and navigate to project
    zellij -d -s "${project_name}"
    ZELLIJ_SESSION_NAME="${project_name}" zellij action write-chars "cd ${project_path}"
    ZELLIJ_SESSION_NAME="${project_name}" zellij action write 13
    
    # Start Claude Code
    ZELLIJ_SESSION_NAME="${project_name}" zellij action write-chars "claude"
    ZELLIJ_SESSION_NAME="${project_name}" zellij action write 13
    
    # Add development server pane if package.json exists
    if [[ -f "${project_path}/package.json" ]]; then
        ZELLIJ_SESSION_NAME="${project_name}" zellij action new-pane
        ZELLIJ_SESSION_NAME="${project_name}" zellij action write-chars "npm run dev"
        ZELLIJ_SESSION_NAME="${project_name}" zellij action write 13
    fi
}

# Usage: setup_dev_environment "my-project" "/path/to/project"
```

### Session Cleanup
```bash
cleanup_dev_sessions() {
    zellij ls | grep -v "^$" | while read session; do
        session_name=$(echo $session | awk '{print $1}')
        echo "Found session: $session_name"
        # Optionally kill specific sessions
        # zellij kill-session "$session_name"
    done
}
```

## Use Cases

- **Organized Development**: Separate sessions for different parts of a project
- **Persistent Environments**: Long-running development setups that survive terminal closures
- **Automated Setup**: Scripts to quickly bootstrap common development patterns
- **Resource Isolation**: Keep different projects and their processes separated