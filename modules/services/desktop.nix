{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.desktop;
in
{
  options.services.desktop = {
    enable = lib.mkEnableOption "desktop services";

    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable printing services";
      };

      epson = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Epson printer drivers";
        };
      };
    };
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

    # Printing services
    services.printing = lib.mkIf cfg.printing.enable {
      enable = true;
      startWhenNeeded = true;

      drivers =
        with pkgs;
        [
          # Generic drivers
          gutenprint
          gutenprintBin
          cups-filters
        ]
        ++ lib.optionals cfg.printing.epson.enable (
          with pkgs;
          [
            # Epson-specific drivers
            epson-escpr
            epson-escpr2
          ]
        );

      # Enable automatic printer discovery
      browsing = true;
      defaultShared = false;
    };

    # Enable Avahi for network printer discovery
    services.avahi = lib.mkIf cfg.printing.enable {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # System packages for printer management
    environment.systemPackages = lib.mkIf cfg.printing.enable (
      with pkgs;
      [
        system-config-printer # GUI printer configuration
      ]
    );

    # Firewall rules for printing
    networking.firewall = lib.mkIf cfg.printing.enable {
      allowedTCPPorts = [ 631 ]; # CUPS web interface
      allowedUDPPorts = [ 631 ]; # CUPS browsing
    };
  };
}
