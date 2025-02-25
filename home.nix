{ inputs, pkgs, ... }: let 
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/2y/wallhaven-2yrwzy.jpg";
    hash = "sha256-OJBIdULF8iElf2GNl2Nmedh5msVSSWbid2RtYM5Cjog=";
  };
in {
  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  home.stateVersion = "24.11";
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    btop
    htop

    gnumake
    fnm
    gcc

    go
    lua
    zig

    vlc
    spotify

    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-history

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "obsidian.desktop"
        "com.vivaldi.Vivaldi.desktop"
        "code.desktop"
        "com.mitchellh.ghostty.desktop"
      ];
      disable-user-extensions = false;
      disabled-extensions = "disabled";
      enabled-extensions = [
        "caffeine@patapon.info"
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "clipboard-history@alexsaveau.dev"
      ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      search = [ "<Super>d" ];
    };

    "org/gnome/shell/extensions/clipboard-history" = {
      "display-mode" = 0;
      "next-entry" = [ "<Shift><Alt>j" ];
      "prev-entry" = [ "<Shift><Alt>k" ];
      "toggle-menu" = [ "<Super>v" ];
    };

    "org/gnome/desktop/peripherals/mouse" = {
      "natural-scoll" = false;
    };

    "org/gnome/desktop/interface" = {
      "show-battery-percentage" = true;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "${wallpaper}";
      picture-uri-dark = "${wallpaper}";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      "scroll-action" = "cycle-windows";
    };
  };

  programs.home-manager.enable = true;

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
        plugins = [
          "git"
          "docker"
          "ssh-agent"
          "dotenv"
        ];
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

    # TODO: zoxide enable like a program

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
