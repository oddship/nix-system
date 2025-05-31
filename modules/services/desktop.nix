{ lib, config, pkgs, ... }:
let
  cfg = config.services.desktop;
in
{
  options.services.desktop = {
    enable = lib.mkEnableOption "desktop services";
  };

  config = lib.mkIf cfg.enable {
    # Audio with PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Hardware support
    hardware.pulseaudio.enable = false; # Use PipeWire instead

    # Bluetooth support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Printing support
    services.printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint hplip ];
    };

    # Network services
    services.tailscale.enable = true;
    services.netbird.enable = true;

    # File synchronization
    services.syncthing = {
      enable = true;
      user = "rhnvrm";
      dataDir = "/home/rhnvrm";
      openDefaultPorts = true;
    };

    # Power management
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    # Media keys and laptop features
    services.actkbd.enable = true;
    
    # Enable CUPS for printing
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable touchpad support
    services.libinput.enable = true;

    # Enable automatic device mounting
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    # Enable geoclue2 for location services
    services.geoclue2.enable = true;

    # Enable accounts daemon
    services.accounts-daemon.enable = true;

    # Enable gnome keyring
    services.gnome.gnome-keyring.enable = true;
  };
}