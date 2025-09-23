#!/usr/bin/env bash

# kill-process.sh
# ---------------
# Fuzzy-find a running process by name and kill it after confirmation.
# Useful for quickly finding and stopping applications by their process name.

set -euo pipefail

# Function: list_processes
# -----------------------
# Uses ps to list all processes for fzf selection.
# Output columns: PID, USER, %CPU, %MEM, COMMAND
list_processes() {
  echo "Scanning for running processes..." >&2
  ps aux --no-headers | awk '{
    pid = $2
    user = $1
    cpu = $3
    mem = $4
    # Join the rest as command
    cmd = ""
    for (i=11; i<=NF; i++) {
      if (i > 11) cmd = cmd " "
      cmd = cmd $i
    }
    printf "%-8s %-12s %-5s %-5s %s\n", pid, user, cpu, mem, cmd
  }'
}

# Function: check_specific_process
check_specific_process() {
  local name="$1"
  echo "Checking specifically for process containing '$name'..." >&2
  ps aux | grep -i "$name" | grep -v grep >/dev/null 2>&1 || {
    echo "No process found containing '$name'" >&2
    return 1
  }
}

# Main execution
echo "=== Process Kill Utility ==="

# If argument provided, check specific process first
if [[ $# -gt 0 ]]; then
  process_name="$1"
  echo "Checking for process containing '$process_name' specifically..."
  if check_specific_process "$process_name"; then
    echo "Found process(es) containing '$process_name'!"
  else
    echo "No process found containing '$process_name'. Showing all running processes..."
  fi
fi

# Get all processes and use fzf
processes_output=$(list_processes)

if [[ -z "$processes_output" ]]; then
  echo "No running processes found."
  exit 0
fi

echo "Total running processes found: $(echo "$processes_output" | wc -l)" >&2

# Use fzf to select a process interactively.
selection=$(echo "$processes_output" | fzf \
  --header="Select a process to inspect/kill (PID  USER  %CPU  %MEM  COMMAND)" \
  --query="${1:-}" \
  --ansi)

# If nothing selected, exit gracefully.
if [[ -z "${selection:-}" ]]; then
  echo "Cancelled."
  exit 0
fi

# Extract fields from the selected row.
pid=$(echo "$selection" | awk '{print $1}')
user=$(echo "$selection" | awk '{print $2}')
cpu=$(echo "$selection" | awk '{print $3}')
mem=$(echo "$selection" | awk '{print $4}')
cmd=$(echo "$selection" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}' | sed 's/ $//')

# Show basic info about the selected process.
echo
echo "Selected process:"
echo "  PID:      $pid"
echo "  USER:     $user"
echo "  %CPU:     $cpu"
echo "  %MEM:     $mem"
echo "  COMMAND:  $cmd"
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