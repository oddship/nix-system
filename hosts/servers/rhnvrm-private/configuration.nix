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
    ../../../modules/services/tailscale-node.nix
    ../../../modules/services/gitea-private.nix
    ../../../modules/services/garage-s3.nix
    ../../../modules/services/vaultwarden-private.nix
    ../../../modules/services/caddy-tailscale.nix
    ../../../modules/services/web-terminal.nix
  ];

  networking.hostName = "rhnvrm-private";

  # IPv6-only static networking for Hetzner
  networking.useDHCP = false;
  networking.interfaces.ens3 = {
    ipv6.addresses = [
      {
        address = "PLACEHOLDER_IPV6";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };
  networking.nameservers = [
    "2a01:4ff:ff00::add:1"
    "2a01:4ff:ff00::add:2"
  ];

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
    ];
  };

  # Dev tools for running bosun on server
  environment.systemPackages = with pkgs; [
    bun
    nodejs_22
    tmux
    just
    git
    jq
    ripgrep
    fd
    ttyd # web terminal
  ];

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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # Single secrets env file for all services
  age.secrets.rhnvrm-private-env = {
    file = ../../../secrets/rhnvrm-private-env.age;
    owner = "root";
    mode = "400";
  };

  # Enable all services
  services.rhnvrm-tailscale.enable = true;
  services.rhnvrm-gitea.enable = true;
  services.rhnvrm-garage.enable = true;
  services.rhnvrm-vaultwarden.enable = true;
  services.rhnvrm-caddy-tailscale.enable = true;
  services.rhnvrm-web-terminal.enable = true;

  system.stateVersion = "24.11";
}
