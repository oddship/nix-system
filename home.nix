{ inputs, pkgs, ... }:
{
  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    btop
    htop

    gnumake
    fnm
    gcc

    go
    lua
    zig

    git
    curl
    wget
    ripgrep
    fd
    age
    tree
    jq
    tmux
    zoxide
    eza
    ncdu
    websocat
  ];

  # Example: Git config
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";
  };

  # WM
  programs.kitty = {
    enable = true;
  };

  programs.ghostty = {
    enable = true;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Noto Sans Medium 11";
  };

  # Zsh
  programs = {
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "ssh-agent" "dotenv" ];
        theme = "robbyrussell";
      };
      shellAliases = {
        ls = "eza --icons=always";
        cd = "z";
        sudo = "sudo --preserve-env=PATH env";
      };
      initExtra = ''
        export PATH=$HOME/go/bin:$PATH
        # zoxide integration = for z 
        eval "$(zoxide init zsh)"
        # fnm integration for node js
        eval "$(fnm env --use-on-cd)"
        # ssh-agent config
        zstyle :omz:plugins:ssh-agent lazy yes
        zstyle :omz:plugins:ssh-agent identities id_ed25519
        zstyle :omz:plugins:ssh-agent lifetime 1h
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      extraConfig = ''
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
      '';
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
