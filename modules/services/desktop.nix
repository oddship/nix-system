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
      pulse.enable = true;
    };

    # Network services
    services.tailscale.enable = true;
    services.netbird.enable = true;

    # File synchronization
    services.syncthing = {
      enable = true;
      user = "rhnvrm";
      dataDir = "/home/rhnvrm";
    };
  };
}