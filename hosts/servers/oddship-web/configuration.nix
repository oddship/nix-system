{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
let
  enableS3SiteHostedSites = true; # serve oddship.net and rohanverma.net from Garage via s3site
  s3siteListen = "127.0.0.1:9001";
  garageEndpoint = "http://rhnvrm-private:3900";
  s3siteHostedSites = {
    oddship = {
      hostname = "oddship.net";
      key = "sites/oddship.net.tar.gz";
    };
    rohanverma = {
      hostname = "rohanverma.net";
      key = "sites/rohanverma.net.tar.gz";
    };
  };
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
    ../../../modules/services/server.nix
    ../../../modules/services/s3site.nix
  ];

  networking.hostName = "oddship-web";

  # GRUB bootloader (disko handles device selection via EF02 partition)
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "rhnvrm"
    ]; # for nixos-rebuild --target-host
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCDqQWyaZr2+cYr+fwvBGnLAd4e6yRGMlgRyp5LgAOV github-actions-deploy"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhMcpB33gW/2TvOLyHCW6IS8a3HKx+kVcYnRxeQXc7k github-actions-s3site"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.server = {
    enable = true;
    webserver.enable = true;
    staticSites = { };
    reverseProxySites = {
      oddship = {
        domain = s3siteHostedSites.oddship.hostname;
        upstream = "http://${s3siteListen}";
      };
      rohanverma = {
        domain = s3siteHostedSites.rohanverma.hostname;
        upstream = "http://${s3siteListen}";
      };
      umami = {
        domain = "analytics.rohanverma.net";
        upstream = "http://127.0.0.1:3000";
      };
    };
  };

  services.s3site = lib.mkIf enableS3SiteHostedSites {
    enable = true;
    package = inputs.s3site.packages.${pkgs.stdenv.hostPlatform.system}.default;
    bucket = "static-sites";
    region = "garage";
    endpoint = garageEndpoint;
    prefix = "sites/";
    listen = s3siteListen;
    controlSocket = "/run/s3site/control.sock";
    storage = "disk";
    dataDir = "/var/lib/s3site/data";
    poll = "5m";
    environmentFile = config.age.secrets.oddship-web-s3site-env.path;
    hostedSites = s3siteHostedSites;
  };

  services.tailscale = lib.mkIf enableS3SiteHostedSites {
    enable = true;

    authKeyFile = config.age.secrets.oddship-web-tailscale-auth.path;
    authKeyParameters = {
      ephemeral = false;
      preauthorized = true;
    };
    extraUpFlags = [ "--advertise-tags=tag:oddship-web" ];
  };

  # Umami web analytics
  services.umami = {
    enable = true;
    createPostgresqlDatabase = true;
    settings = {
      APP_SECRET_FILE = config.age.secrets.umami-app-secret.path;
    };
  };

  # agenix secrets (host key injected by terraform during install)
  age.secrets.cloudflare-api-token.file = ../../../secrets/cloudflare-api-token.age;
  age.secrets.umami-app-secret.file = ../../../secrets/umami-app-secret.age;

  age.secrets.oddship-web-s3site-env = lib.mkIf enableS3SiteHostedSites {
    file = ../../../secrets/oddship-web-s3site-env.age;
    owner = "s3site";
    group = "s3site";
    mode = "0400";
  };
  age.secrets.oddship-web-tailscale-auth = lib.mkIf enableS3SiteHostedSites {
    file = ../../../secrets/oddship-web-tailscale-auth.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # Caddy DNS-01 challenge - use agenix secret via script wrapper
  # Use list format ["" "new"] to clear previous ExecStart and set new one
  systemd.services.caddy = {
    serviceConfig = {
      LoadCredential = "cloudflare-token:${config.age.secrets.cloudflare-api-token.path}";
      ExecStart = lib.mkForce [
        "" # Clear previous ExecStart
        (pkgs.writeShellScript "caddy-start" ''
          export CLOUDFLARE_DNS_API_TOKEN=$(cat $CREDENTIALS_DIRECTORY/cloudflare-token)
          exec ${config.services.caddy.package}/bin/caddy run --config /etc/caddy/caddy_config --adapter caddyfile
        '')
      ];
    };
  };

  system.stateVersion = "24.11";
}
