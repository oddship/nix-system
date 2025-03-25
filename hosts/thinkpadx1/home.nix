{
  inputs,
  pkgs,
  gitConfigExtra ? "",
  ...
}:
let
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/2y/wallhaven-2yrwzy.jpg";
    hash = "sha256-OJBIdULF8iElf2GNl2Nmedh5msVSSWbid2RtYM5Cjog=";
  };

  # TODO: syncthingtray does not work on first boot correctly
  autostartPrograms = [
    pkgs.syncthingtray-minimal
    pkgs.ktailctl
  ];
in
{
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

    thunderbird

    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-history
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell

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

  # TODO: figure out default browser.
  # this does not work, or does (?) unsure.
  # For now manually run `xdg-settings set default-web-browser com.vivaldi.Vivaldi.desktop`
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "com.vivaldi.Vivaldi.desktop" ];
    "text/xml" = [ "com.vivaldi.Vivaldi.desktop" ];
    "x-scheme-handler/http" = [ "com.vivaldi.Vivaldi.desktop" ];
    "x-scheme-handler/https" = [ "com.vivaldi.Vivaldi.desktop" ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "ticktick.desktop"
        "obsidian.desktop"
        "com.vivaldi.Vivaldi.desktop" # TODO: switch this out with chromium
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
        "just-perfection-desktop@just-perfection"
        "blur-my-shell@aunetx"
      ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      "toggle-message-tray" = [ "<Shift><Super>v" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      search = [ "<Super>d" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "ghostty";
      name = "Launch Ghostty";
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

    "org/gnome/desktop/peripherals/touchpad" = {
      "natural-scroll" = false;
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
      shortcut = [ "<Shift><Super>q" ];
    };

    "org/gnome/shell/extensions/just-perfection" = {
      "workspace-wrap-around" = true;
      "animation" = 3;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      whitelist = [ "com.mitchellh.ghostty" ];
      blur = true;
      dynamic-opacity = true;
    };

    "org/gnome/shell/extensions/workspace-indicator" = {
      "embed-previews" = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      "workspace-names" = [
        "Notes"
        "Browser"
        "Code"
        "Terminal"
      ];
    };
  };

  programs.home-manager.enable = true;

  # Example: Git config
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";

    includes = [
      {
        path = gitConfigExtra; # TODO: need to figure out a better way to do this
      }
    ];
  };

  # WM
  programs.kitty = {
    enable = true;
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
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
        export EDITOR="vim"

        # fnm integration for node js
        eval "$(fnm env --use-on-cd)"

        # necessary for tmux etc on remotes where term info is not available
        if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
            export TERM=xterm-256color
        fi
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
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

  # Autostart XDG for gnome (ref: https://github.com/nix-community/home-manager/issues/3447)
  home.file = builtins.listToAttrs (
    map (pkg: {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
        if pkg ? desktopItem then
          {
            # Application has a desktopItem entry.
            # Assume that it was made with makeDesktopEntry, which exposes a
            # text attribute with the contents of the .desktop file
            text = pkg.desktopItem.text;
          }
        # For ktailctl, /share/applications/org.fkoehler.KTailctl.desktop is the name so add a manual
        # entry for it
        else if pkg.pname == "ktailctl" then
          {
            source = (pkg + "/share/applications/org.fkoehler.KTailctl.desktop");
          }
        else
          {
            # Application does *not* have a desktopItem entry. Try to find a
            # matching .desktop name in /share/apaplications
            source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
          };
    }) autostartPrograms
  );
}
