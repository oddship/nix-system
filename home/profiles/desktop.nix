{ inputs, pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://images.unsplash.com/photo-1644700057440-f05c649e21b9";
    hash = "sha256-D1e6G+/5UfGMcDrJuKQXdRxlHaEk9tyM2W/n15LP79M=";
  };

  autostartPrograms = [
    pkgs.syncthingtray-minimal
    pkgs.ktailctl
  ];
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ../programs/shell.nix
    ../programs/terminal.nix
    ../programs/git.nix
    ../programs/neovim.nix
    ../programs/tmux.nix
    ../programs/zellij.nix
    ../programs/lazygit.nix
    ../programs/claude-skills.nix
  ];

  # Catppuccin theme configuration
  catppuccin = {
    flavor = "mocha";
    accent = "blue";
  };

  # Enable catppuccin for specific applications
  catppuccin.ghostty.enable = true;

  # GTK theming (manual since catppuccin GTK port was archived)
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-blue-standard+rimless,black";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        tweaks = [ "rimless" "black" ]; # optional tweaks
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "blue";
        flavor = "mocha";
      };
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic"; # Keep your existing cursor
      package = pkgs.bibata-cursors;
    };
  };

  # Note: pointerCursor disabled since bibata-cursors is configured above

  home = {
    username = "rhnvrm";
    homeDirectory = "/home/rhnvrm";
    stateVersion = "24.11";
  };

  home.packages = with pkgs; [
    btop
    htop

    gnumake
    fnm
    gcc

    go
    python3
    lua
    zig

    vlc

    thunderbird

    appflowy

    gnomeExtensions.caffeine
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-history
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.astra-monitor

    git
    curl
    wget
    ripgrep
    fd
    age
    tree
    jq
    sqlite
    duckdb
    tmux
    zoxide
    eza
    ncdu
    websocat
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "zen-beta.desktop" ];
    "text/xml" = [ "zen-beta.desktop" ];
    "x-scheme-handler/http" = [ "zen-beta.desktop" ];
    "x-scheme-handler/https" = [ "zen-beta.desktop" ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      show-battery-percentage = false;
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "com.mitchellh.ghostty.desktop"
        "ticktick.desktop"
        "obsidian.desktop"
        "zen-beta.desktop"
        "code.desktop"
        "dev.zed.Zed.desktop"
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
        "monitor@astraext.github.io"
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
      "natural-scroll" = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      "natural-scroll" = false;
    };

    # Merged with interface section above

    "org/gnome/desktop/background" = {
      picture-uri = "${wallpaper}";
      picture-uri-dark = "${wallpaper}";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      "scroll-action" = "switch-workspace";
      shortcut = [ "<Shift><Super>q" ];
      "multi-monitor" = true;
      "isolate-monitors" = true;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      "workspace-wrap-around" = true;
      "animation" = 1;
      "workspace-switcher-should-show" = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      whitelist = [ ];
      blur = true;
      dynamic-opacity = false;
    };

    "org/gnome/shell/extensions/astra-monitor" = {
      # Astra Monitor will use default settings
      # Can be configured interactively via extension preferences
    };

    "org/gnome/shell/extensions/workspace-indicator" = {
      "embed-previews" = false;
    };

    "org/gnome/mutter" = {
      "dynamic-workspaces" = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      "workspace-names" = [
        "Notes"
        "Browser"
        "Code"
        "Terminal"
      ];
      "button-layout" = "appmenu:minimize,maximize,close";
    };
  };

  programs.home-manager.enable = true;

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
            # matching .desktop name in /share/applications
            source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
          };
    }) autostartPrograms
  );
}
