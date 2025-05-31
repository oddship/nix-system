{ config, lib, pkgs, gitConfigExtra ? "", ... }:
{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";

    # Include external git config
    includes = [
      {
        path = gitConfigExtra;
        condition = "gitdir:~/";
      }
    ];

    # Git aliases
    aliases = {
      # Status and info
      st = "status";
      s = "status -s";
      sb = "status -sb";
      
      # Commits
      c = "commit";
      cm = "commit -m";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      
      # Branches
      b = "branch";
      ba = "branch -a";
      bd = "branch -d";
      bD = "branch -D";
      co = "checkout";
      cob = "checkout -b";
      
      # Diffs
      d = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      dw = "diff --word-diff";
      
      # Logs
      l = "log --oneline";
      lg = "log --oneline --graph --decorate";
      ll = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate --numstat";
      ld = "log --pretty=format:'%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]' --decorate --date=relative";
      
      # Stash
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";
      sa = "stash apply";
      
      # Remote
      f = "fetch";
      p = "push";
      pl = "pull";
      pr = "pull --rebase";
      
      # Reset
      unstage = "reset HEAD --";
      uncommit = "reset --soft HEAD~1";
      
      # Utils
      aliases = "config --get-regexp '^alias\\.'";
      whoami = "config user.email";
      contrib = "shortlog --summary --numbered";
      
      # Find
      find = "!git ls-files | grep -i";
      grep = "grep -Ii";
    };

    # Extra configuration
    extraConfig = {
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        pager = "delta";
      };

      init = {
        defaultBranch = "main";
      };

      pull = {
        rebase = true;
      };

      push = {
        default = "current";
        autoSetupRemote = true;
      };

      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };

      diff = {
        tool = "vimdiff";
        colorMoved = "default";
      };

      color = {
        ui = true;
        branch = "auto";
        diff = "auto";
        status = "auto";
      };

      rerere = {
        enabled = true;
      };

      fetch = {
        prune = true;
      };

      rebase = {
        autoStash = true;
      };

      help = {
        autocorrect = 1;
      };

      credential = {
        helper = "cache --timeout=3600";
      };
    };

    # Git ignore patterns
    ignores = [
      # OS files
      ".DS_Store"
      "Thumbs.db"
      
      # Editor files
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.sublime-*"
      
      # Build files
      "*.log"
      "*.tmp"
      "*.temp"
      ".cache/"
      "dist/"
      "build/"
      
      # Language specific
      "__pycache__/"
      "*.pyc"
      "node_modules/"
      ".env"
      ".env.local"
      
      # Nix
      "result"
      "result-*"
    ];

    # Enable delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        syntax-theme = "Tokyo Night";
        features = "decorations";
        whitespace-error-style = "22 reverse";
        
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
          hunk-header-decoration-style = "cyan box ul";
        };
        
        line-numbers = {
          line-numbers-left-style = "cyan";
          line-numbers-right-style = "cyan";
          line-numbers-minus-style = "124";
          line-numbers-plus-style = "28";
        };
      };
    };

    # Enable git LFS
    lfs = {
      enable = true;
    };
  };

  # Additional git tools
  home.packages = with pkgs; [
    # Git tools
    gh  # GitHub CLI
    gitlab  # GitLab CLI
    gitui  # Terminal UI for git
    lazygit  # Simple terminal UI for git
    git-absorb  # Automatic fixup commits
    git-filter-repo  # History rewriting
    
    # Diff tools
    difftastic  # Structural diff tool
    meld  # Visual diff tool
    
    # Commit tools
    commitizen  # Conventional commits
    cocogitto  # Conventional commits tool
  ];
}