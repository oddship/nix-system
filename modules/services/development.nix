{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.development;
in
{
  options.services.development = {
    enable = lib.mkEnableOption "development services";

    docker = {
      enable = lib.mkEnableOption "Docker virtualization";
      enableOnBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Docker on boot";
      };
      storageDriver = lib.mkOption {
        type = lib.types.str;
        default = "overlay2";
        description = "Docker storage driver to use";
      };
    };

    gaming = {
      enable = lib.mkEnableOption "gaming support (Steam)";
    };

    virtualisation = {
      enable = lib.mkEnableOption "additional virtualization support";
      libvirtd = lib.mkEnableOption "libvirtd for VMs";
      podman = lib.mkEnableOption "Podman container runtime";
    };
  };

  config = lib.mkIf cfg.enable {
    # Docker setup
    virtualisation.docker = lib.mkIf cfg.docker.enable {
      enable = true;
      storageDriver = cfg.docker.storageDriver;
      enableOnBoot = cfg.docker.enableOnBoot;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
      daemon.settings = {
        features = {
          buildkit = true;
        };
        live-restore = true;
        log-driver = "json-file";
        log-opts = {
          max-size = "10m";
          max-file = "3";
        };
      };
    };

    # Gaming with Steam
    programs.steam = lib.mkIf cfg.gaming.enable {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # Additional gaming support
    hardware.graphics = lib.mkIf cfg.gaming.enable {
      enable = true;
      enable32Bit = true;
    };

    # Gamemode for performance
    programs.gamemode.enable = lib.mkIf cfg.gaming.enable true;

    # Additional virtualization
    virtualisation.libvirtd = lib.mkIf cfg.virtualisation.libvirtd {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf.enable = true;
        runAsRoot = false;
      };
    };

    # Podman as Docker alternative
    virtualisation.podman = lib.mkIf cfg.virtualisation.podman {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Development tools services
    services.lorri.enable = true; # Nix shell helper
    programs.direnv.enable = true; # Directory-based environments


    # Android development support
    programs.adb.enable = true;

    # Enable wireshark for network debugging
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
