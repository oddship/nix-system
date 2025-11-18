{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.gnome;
in
{
  options.desktop.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # GUI sudo prompt for CLI tools
    security.sudo.extraConfig = ''
      Defaults env_keep += "SUDO_ASKPASS"
    '';
    environment.sessionVariables.SUDO_ASKPASS =
      let
        askpass = pkgs.writeShellApplication {
          name = "sudo-askpass";
          runtimeInputs = [ pkgs.zenity ];
          text = ''
            zenity --password --title="Authentication Required"
          '';
        };
      in
      "${askpass}/bin/sudo-askpass";

    # X11 and GNOME
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # GNOME keyring
    security.pam.services.login.enableGnomeKeyring = true;

    # Intel graphics optimization
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VAAPI (iHD)
        intel-compute-runtime # OpenCL
      ];
    };

    # Wayland and graphics optimizations
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1"; # Wayland support for Electron apps
      LIBVA_DRIVER_NAME = "iHD"; # Force Intel iHD driver
    };

    # Remove unwanted GNOME packages
    environment.gnome.excludePackages = with pkgs; [
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
    ];

    # GNOME utilities
    environment.systemPackages = with pkgs; [
      zenity # For GUI sudo prompts
      gnome-tweaks
      gnome-extension-manager
      bibata-cursors
    ];

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
        noto-fonts-color-emoji
        noto-fonts
        jetbrains-mono
        inter
      ];
    };

    # Touchpad support
    services.libinput.enable = true;

    # Bluetooth
    hardware.bluetooth.enable = true;

    # keyboard
    hardware.keyboard.qmk.enable = true;
  };
}
