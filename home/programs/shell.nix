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
    };
    initContent = ''
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
