{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "dotenv"
      ];
      theme = "robbyrussell";
    };
    shellAliases = {
      ls = "eza --icons=always";
      sudo = "sudo --preserve-env=PATH env";
      zed = "zeditor";

      # Tmux aliases
      tm = "tmux";
      tma = "tmux attach-session -t";
      tmn = "tmux new-session -s";
      tml = "tmux list-sessions";
      tmk = "tmux kill-session -t";
      tms = "tmux-session";
      tmd = "tmux-session --dev";

      # Zellij aliases
      zj = "za";
      zja = "zellij attach";
      zjl = "zellij list-sessions";
      zjk = "zellij kill-session";
      zjf = "zf";

      # Git worktree aliases
    };
    initContent = ''
      # Add user-specific local bin directory to PATH
      export PATH=$HOME/.local/bin:$PATH
      # Add Go binaries to PATH
      export PATH=$HOME/go/bin:$PATH
      export EDITOR="vim"

      # fnm integration for node js
      eval "$(fnm env --use-on-cd)"

      # necessary for tmux etc on remotes where term info is not available
      if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
          export TERM=xterm-256color
      fi

      # Nix environment indicator
      if [[ -n "$IN_NIX_SHELL" ]]; then
        export PS1="❄️  $PS1"
      fi

      # Function to print timestamp before each prompt
      prompt_timestamp() {
        print -rP "%F{242}%T%f"
      }
      # Add to precmd hook array (runs before each prompt)
      precmd_functions+=(prompt_timestamp)

      # Find and cd function using fzf
      fcd() {
          local dir
          dir=$(find ''${1:-.} -type d -not -path '*/.*' 2>/dev/null | fzf +m) && cd "$dir"
      }

      # Tmux session functions
      tmux-dev() {
          local session_name
          session_name=$(basename "$PWD")
          
          if tmux has-session -t "$session_name" 2>/dev/null; then
              echo "Development session '$session_name' already exists!"
              tmux attach-session -t "$session_name"
              return 0
          fi
          
          echo "Creating development session: $session_name"
          tmux new-session -d -s "$session_name" -c "$PWD"
          tmux send-keys -t "$session_name:0" "nvim" C-m
          tmux split-window -t "$session_name:0" -h -c "$PWD"
          tmux split-window -t "$session_name:0" -v -c "$PWD"
          tmux select-pane -t "$session_name:0.0"
          tmux attach-session -t "$session_name"
      }

      # Quick tmux session attach with fzf
      tmux-attach() {
          local session
          session=$(tmux ls 2>/dev/null | cut -d: -f1 | fzf --prompt="Select session: " --height=40% --border)
          if [ -n "$session" ]; then
              tmux attach-session -t "$session"
          fi
      }

      # Zellij smart session management - uses folder name or provided name
      za() {
          local session_name=''${1:-$(basename "$PWD")}
          zellij attach "$session_name" || zellij -s "$session_name"
      }

      # Git worktree cd function
      cdgw() {
          local dir
          dir=$(git-worktree-search)
          if [[ -n "$dir" ]]; then
              cd "$dir"
          fi
      }

      # Fuzzy Zellij session selector - combines zjl + za with fzf
      zf() {
          local sessions current_session action session_name in_zellij
          
          # Check if we're already inside a Zellij session
          in_zellij=""
          if [[ -n "$ZELLIJ" ]]; then
              in_zellij="true"
          fi
          
          # Get all sessions (active and exited) - parse the colored output properly
          sessions=$(zellij list-sessions 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}' | sort -u)
          current_session=$(zellij list-sessions 2>/dev/null | grep "(current)" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $1}')
          
          # Create menu with options
          local options=""
          if [[ -n "$sessions" ]]; then
              # Add existing sessions to options
              while IFS= read -r session; do
                  if [[ "$session" == "$current_session" ]]; then
                      options="$options● $session (current)\n"
                  else
                      options="$options○ $session\n"
                  fi
              done <<< "$sessions"
              options="$options---\n"
          fi
          
          # Add action options
          options="$options+ New session (current directory: $(basename "$PWD"))\n"
          options="$options+ New session (custom name)\n"
          options="$options🗑 Kill session"
          
          # Use fzf to select
          local selection
          local prompt_text="Zellij Sessions"
          if [[ -n "$in_zellij" ]]; then
              prompt_text="Zellij Sessions (Inside Zellij - will switch)"
          fi
          
          selection=$(echo -e "$options" | fzf --prompt="$prompt_text: " \
                                              --height=60% \
                                              --border \
                                              --preview='
                                                  if [[ {} =~ ^[●○] ]]; then
                                                      session=$(echo {} | sed "s/^[●○] //" | sed "s/ (current)$//")
                                                      echo "Session: $session"
                                                      echo "---"
                                                      # Show full session details with status
                                                      zellij list-sessions 2>/dev/null | sed "s/\x1b\[[0-9;]*m//g" | grep "^$session " || echo "No details available"
                                                      echo ""
                                                      if [[ -n "$ZELLIJ" ]]; then
                                                          echo "Action: Switch to this session (inside Zellij)"
                                                      else
                                                          echo "Action: Attach to this session"
                                                      fi
                                                  elif [[ {} == *"current directory"* ]]; then
                                                      echo "Will create session: $(basename "$PWD")"
                                                      echo "Directory: $PWD"
                                                      echo "---"
                                                      if [[ -n "$ZELLIJ" ]]; then
                                                          echo "This will create a new session and switch to it (inside Zellij)."
                                                      else
                                                          echo "This will create a new Zellij session using the current directory name."
                                                      fi
                                                  elif [[ {} == *"custom name"* ]]; then
                                                      echo "Create Custom Session"
                                                      echo "---"
                                                      if [[ -n "$ZELLIJ" ]]; then
                                                          echo "Create a new session with custom name and switch to it (inside Zellij)."
                                                      else
                                                          echo "You will be prompted to enter a custom session name."
                                                      fi
                                                  elif [[ {} == *"Kill session"* ]]; then
                                                      echo "Kill Session"
                                                      echo "---"
                                                      echo "Select a session to terminate permanently."
                                                  fi
                                              ')
          
          if [[ -z "$selection" ]]; then
              return 0
          fi
          
          case "$selection" in
              "● "*" (current)")
                  # Already in this session, just show info
                  session_name=$(echo "$selection" | sed 's/^● //' | sed 's/ (current)$//')
                  echo "Already in session: $session_name"
                  ;;
              "○ "*)
                  # Attach/switch to existing session
                  session_name=$(echo "$selection" | sed 's/^○ //')
                  if [[ -n "$in_zellij" ]]; then
                      echo "To switch to session '$session_name':"
                      echo "  Use session manager: Ctrl+o + w"
                      echo "  Or detach and attach: Ctrl+o + d, then run: zj $session_name"
                  else
                      echo "Attaching to session: $session_name"
                      zellij attach "$session_name"
                  fi
                  ;;
              "+ New session (current directory: "*)
                  # Create new session with current directory name
                  session_name=$(basename "$PWD")
                  if [[ -n "$in_zellij" ]]; then
                      echo "To create new session '$session_name':"
                      echo "  Detach: Ctrl+o + d, then run: zj $session_name"
                  else
                      echo "Creating new session: $session_name"
                      za "$session_name"
                  fi
                  ;;
              "+ New session (custom name)")
                  # Create new session with custom name
                  echo -n "Enter session name: "
                  read session_name
                  if [[ -n "$session_name" ]]; then
                      if [[ -n "$in_zellij" ]]; then
                          echo "To create new session '$session_name':"
                          echo "  Detach: Ctrl+o + d, then run: zj $session_name"
                      else
                          echo "Creating new session: $session_name"
                          za "$session_name"
                      fi
                  fi
                  ;;
              "🗑 Kill session")
                  # Kill session selector
                  if [[ -n "$sessions" ]]; then
                      local kill_session
                      kill_session=$(echo -e "$sessions" | fzf --prompt="Kill session: " \
                                                               --height=40% \
                                                               --border \
                                                               --preview='echo "Will kill session: {}"')
                      if [[ -n "$kill_session" ]]; then
                          echo "Killing session: $kill_session"
                          zellij kill-session "$kill_session"
                      fi
                  else
                      echo "No sessions to kill"
                  fi
                  ;;
          esac
      }
    '';
  };

  # Zoxide for smart cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        log_filter = "^$";
      };
    };
  };

  # Fzf for fuzzy finding
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
