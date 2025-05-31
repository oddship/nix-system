{ config, lib, pkgs, ... }:
let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
    
    minimalInstall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use minimal GNOME installation";
    };
  };

  config = lib.mkIf cfg.enable {
    # X11 and GNOME
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    # GNOME keyring
    security.pam.services.login.enableGnomeKeyring = true;

    # Wayland optimizations
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # Remove unwanted GNOME packages
    environment.gnome.excludePackages = lib.mkIf cfg.minimalInstall (with pkgs; [
      orca
      evince
      geary
      gnome-disk-utility
      gnome-backgrounds
      gnome-tour
      gnome-user-docs
      baobab
      epiphany
      gnome-text-editor
      gnome-characters
      gnome-console
      gnome-logs
      gnome-maps
      gnome-music
      gnome-weather
      simple-scan
      snapshot
      totem
      yelp
      gnome-software
      gnome-connections
      gnome-contacts
      gnome-calendar
      gnome-clocks
    ]);

    # GNOME utilities
    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnome-extension-manager
      bibata-cursors
      gnomeExtensions.appindicator
      dconf-editor
    ];

    # Enable GNOME services
    services.udev.packages = with pkgs; [ gnome-settings-daemon ];
    services.dbus.packages = with pkgs; [ gnome-session ];

    # XDG portal for Flatpak/Wayland
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    # Fonts
    fonts = {
      enableDefaultPackages = true;
      fontconfig.useEmbeddedBitmaps = true;
      packages = with pkgs; [
        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        nerd-fonts.jetbrains-mono
        font-awesome_5
        noto-fonts-emoji
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        jetbrains-mono
        inter
        roboto
        ubuntu_font_family
      ];
    };

    # QT theme integration
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    # Hardware keyboard support
    hardware.keyboard.qmk.enable = lib.mkDefault true;
  };
}