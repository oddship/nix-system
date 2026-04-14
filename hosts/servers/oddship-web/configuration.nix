{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
let
  enableS3SiteCanary = false; # rollback: keep rohanverma.net on static root until oddship-web has a valid tailscale auth key
  s3siteListen = "127.0.0.1:9001";
  garageEndpoint = "http://rhnvrm-private:3900";
  s3siteHostedSites = {
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
    staticSites = {
      oddship = {
        domain = "oddship.net";
        root = inputs.oddship-site.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
    } // lib.optionalAttrs (!enableS3SiteCanary) {
      rohanverma = {
        domain = "rohanverma.net";
        root = inputs.rohanverma-site.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };
    };
    reverseProxySites = {
      umami = {
        domain = "analytics.rohanverma.net";
        upstream = "http://127.0.0.1:3000";
      };
    } // lib.optionalAttrs enableS3SiteCanary {
      rohanverma = {
        domain = s3siteHostedSites.rohanverma.hostname;
        upstream = "http://${s3siteListen}";
      };
    };
  };

  services.s3site = lib.mkIf enableS3SiteCanary {
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
    poll = "10m";
    environmentFile = config.age.secrets.oddship-web-s3site-env.path;
    hostedSites = s3siteHostedSites;
  };

  services.tailscale.enable = enableS3SiteCanary;

  systemd.services.tailscale-auth = lib.mkIf enableS3SiteCanary {
    description = "Tailscale headless authentication for oddship-web";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [
      "network-online.target"
      "tailscaled.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = config.age.secrets.oddship-web-tailscale-auth.path;
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.tailscale}/bin/tailscale up --auth-key=$TAILSCALE_AUTH_KEY'";
    };
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

  age.secrets.oddship-web-s3site-env = lib.mkIf enableS3SiteCanary {
    file = ../../../secrets/oddship-web-s3site-env.age;
    owner = "s3site";
    group = "s3site";
    mode = "0400";
  };
  age.secrets.oddship-web-tailscale-auth = lib.mkIf enableS3SiteCanary {
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
