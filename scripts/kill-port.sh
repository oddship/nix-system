#!/usr/bin/env bash

# kill-port.sh
# -------------
# Fuzzy-find a process listening on a TCP port and kill it after confirmation.
# Useful for quickly finding and stopping applications by their port.

set -euo pipefail

# Function: list_ports
# --------------------
# Uses ss to list all processes listening on TCP ports.
# Output columns: PID, PORT, COMMAND, ADDRESS
list_ports() {
  echo "Scanning for listening TCP ports..." >&2
  local output
  output=$(ss -tlnp 2>/dev/null) || {
    echo "Error: Could not run ss command." >&2
    exit 1
  }
  
  if [[ -z "$output" || $(echo "$output" | wc -l) -le 1 ]]; then
    echo "No listening TCP ports found." >&2
    exit 0
  fi
  
  echo "$output" | awk 'NR>1 && $1=="LISTEN" {
    # Parse ss output: State Recv-Q Send-Q Local-Address:Port Peer-Address:Port Process
    local_addr = $4
    process_info = $6
    
    # Extract port from local address
    if (match(local_addr, /:([0-9]+)$/, port_match)) {
      port = port_match[1]
      addr = substr(local_addr, 1, RSTART-1)
    } else {
      addr = local_addr
      port = "unknown"
    }
    
    # Extract PID and command from process info like users:(("zola",pid=22382,fd=18))
    pid = "unknown"
    cmd = "unknown"
    if (match(process_info, /pid=([0-9]+)/, pid_match)) {
      pid = pid_match[1]
    }
    if (match(process_info, /"([^"]+)"/, cmd_match)) {
      cmd = cmd_match[1]
    }
    
    printf "%-8s %-8s %-15s %s\n", pid, port, cmd, addr
  }'
}

# Function: check_specific_port
check_specific_port() {
  local port="$1"
  echo "Checking specifically for port $port..." >&2
  ss -tlnp | grep ":$port " >/dev/null 2>&1 || {
    echo "No process found listening on port $port" >&2
    return 1
  }
}

# Main execution
echo "=== Port Kill Utility ==="

# If argument provided, check specific port first
if [[ $# -gt 0 ]]; then
  port="$1"
  echo "Checking port $port specifically..."
  if check_specific_port "$port"; then
    echo "Found process on port $port!"
  else
    echo "No process found on port $port. Showing all listening ports..."
  fi
fi

# Get all ports and use fzf
ports_output=$(list_ports)

if [[ -z "$ports_output" ]]; then
  echo "No listening ports found."
  exit 0
fi

echo "Total listening ports found: $(echo "$ports_output" | wc -l)" >&2

# Use fzf to select a process/port interactively.
selection=$(echo "$ports_output" | fzf \
  --header="Select a port/process to inspect/kill (PID  PORT  CMD  ADDRESS)" \
  --query="${1:-}" \
  --ansi)

# If nothing selected, exit gracefully.
if [[ -z "${selection:-}" ]]; then
  echo "Cancelled."
  exit 0
fi

# Extract fields from the selected row.
pid=$(echo "$selection" | awk '{print $1}')
port=$(echo "$selection" | awk '{print $2}')
cmd=$(echo "$selection" | awk '{print $3}')
address=$(echo "$selection" | awk '{print $4}')

# Show basic info about the selected process/port.
echo
echo "Selected process:"
echo "  PID:      $pid"
echo "  PORT:     $port"
echo "  COMMAND:  $cmd"
echo "  ADDRESS:  $address"
echo

# Show detailed process info with ps.
echo "Full process info:"
ps -fp "$pid"
echo

# Prompt user for confirmation.
read -rp "Kill this process? [y/N]: " confirm

# If confirmed, kill the process using kill -9.
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  if kill -9 "$pid" 2>/dev/null; then
    echo "Process $pid killed."
  else
    echo "Failed to kill process $pid. Trying with sudo..."
    sudo kill -9 "$pid"
    echo "Process $pid killed with sudo."
  fi
else
  echo "Aborted."
fi