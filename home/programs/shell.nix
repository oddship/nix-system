{ config, lib, pkgs, ... }:
{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "dotenv"
        "sudo"
        "history"
        "command-not-found"
      ];
      theme = "robbyrussell";
    };
    
    shellAliases = {
      # Better ls
      ls = "eza --icons=always";
      ll = "eza -la --icons=always";
      la = "eza -a --icons=always";
      lt = "eza --tree --icons=always";
      
      # Better cd
      cd = "z";
      
      # Preserve environment for sudo
      sudo = "sudo --preserve-env=PATH env";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
      
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake .#";
      nrb = "sudo nixos-rebuild build --flake .#";
      nfu = "nix flake update";
      ndev = "nix develop";
      nsh = "nix shell";
      
      # System shortcuts
      vim = "nvim";
      vi = "nvim";
      cat = "bat";
      grep = "rg";
      find = "fd";
    };
    
    initExtra = ''
      # Set default editor
      export EDITOR="nvim"
      export VISUAL="nvim"
      
      # Add local bin to PATH
      export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
      
      # Better history
      export HISTSIZE=10000
      export SAVEHIST=10000
      export HISTFILE="$HOME/.zsh_history"
      
      # fnm integration for Node.js
      if command -v fnm &> /dev/null; then
        eval "$(fnm env --use-on-cd)"
      fi
      
      # Set terminal for SSH compatibility
      if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
        export TERM=xterm-256color
      fi
      
      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # Quick directory navigation
      alias ..="cd .."
      alias ...="cd ../.."
      alias ....="cd ../../.."
      alias .....="cd ../../../.."
    '';
  };
  
  # Zoxide for smart cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
      };
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };
    };
  };
  
  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  
  # Fzf for fuzzy finding
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--preview 'bat --color=always --style=header,grid --line-range=:500 {}'"
    ];
  };
  
  # Bat for better cat
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };
  
  # Eza for better ls
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = true;
  };
}