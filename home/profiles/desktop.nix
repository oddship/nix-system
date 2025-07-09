{ inputs, pkgs, ... }:
let
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/2y/wallhaven-2yrwzy.jpg";
    hash = "sha256-OJBIdULF8iElf2GNl2Nmedh5msVSSWbid2RtYM5Cjog=";
  };

  autostartPrograms = [
    pkgs.syncthingtray-minimal
    pkgs.ktailctl
  ];
in
{
  imports = [
    ../programs/shell.nix
    ../programs/terminal.nix
    ../programs/git.nix
    ../programs/neovim.nix
    ../programs/tmux.nix
  ];

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

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "zen.desktop" ];
    "text/xml" = [ "zen.desktop" ];
    "x-scheme-handler/http" = [ "zen.desktop" ];
    "x-scheme-handler/https" = [ "zen.desktop" ];
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
        "zen.desktop"
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
      whitelist = [ "com.mitchellh.ghostty" ];
      blur = true;
      dynamic-opacity = true;
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
