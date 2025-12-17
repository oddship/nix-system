{
  config,
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
    ../../../modules/services/server.nix
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
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.server = {
    enable = true;
    webserver.enable = true;
    staticSites.oddship = {
      domain = "oddship.net";
      root = inputs.oddship-site.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
  };

  # agenix secret (host key injected by terraform during install)
  age.secrets.cloudflare-api-token.file = ../../../secrets/cloudflare-api-token.age;

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
