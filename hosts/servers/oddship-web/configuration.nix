{ config, lib, pkgs, inputs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
    ../../../modules/services/server.nix
  ];

  networking.hostName = "oddship-web";

  # Boot loader - GRUB required for Hetzner Cloud
  # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Enable nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # SSH access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # User
  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net"
    ];
  };

  # Root SSH key (needed for terraform nixos-rebuild)
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net"
  ];

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Caddy web server (will be configured after site flake is ready)
  services.server = {
    enable = true;
    webserver.enable = true;
    # staticSites will be added after oddship-site flake is created
  };

  # Cloudflare API token for DNS-01 challenge
  age.secrets.cloudflare-api-token = {
    file = ../../../secrets/cloudflare-api-token.age;
  };

  # Load Cloudflare token for Caddy DNS-01 challenge
  systemd.services.caddy = {
    serviceConfig = {
      LoadCredential = "cloudflare-token:${config.age.secrets.cloudflare-api-token.path}";
    };
    script = lib.mkBefore ''
      export CLOUDFLARE_DNS_API_TOKEN=$(cat $CREDENTIALS_DIRECTORY/cloudflare-token)
    '';
  };

  system.stateVersion = "24.11";
}
