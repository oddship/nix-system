{ config, lib, pkgs, inputs, modulesPath, ... }:
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
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "rhnvrm" ]; # for nixos-rebuild --target-host
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
  };

  # agenix secret (host key injected by terraform during install)
  age.secrets.cloudflare-api-token.file = ../../../secrets/cloudflare-api-token.age;

  # Caddy DNS-01 challenge
  systemd.services.caddy = {
    serviceConfig = {
      LoadCredential = "cloudflare-token:${config.age.secrets.cloudflare-api-token.path}";
    };
    preStart = ''
      export CLOUDFLARE_DNS_API_TOKEN=$(cat $CREDENTIALS_DIRECTORY/cloudflare-token)
    '';
  };

  system.stateVersion = "24.11";
}
