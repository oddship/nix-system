{ config, lib, pkgs, ... }:
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
      cd = "z";
      sudo = "sudo --preserve-env=PATH env";
      zed = "zeditor";
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
  };

  # Fzf for fuzzy finding
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
