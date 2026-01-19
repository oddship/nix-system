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

  networking.hostName = "oddship-clawdbot";

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

  # Claude CLI for OAuth setup (run `claude setup-token` on server)
  # gh CLI for GitHub operations
  environment.systemPackages = with pkgs; [
    claude-code
    gh
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

  # Workaround for nix-clawdbot hardcoded /bin paths
  # See: https://github.com/clawdbot/nix-clawdbot/issues/5
  system.activationScripts.binCompat = ''
    mkdir -p /bin
    ln -sfn /run/current-system/sw/bin/mkdir /bin/mkdir
    ln -sfn /run/current-system/sw/bin/ln /bin/ln
  '';

  # Secret for Discord bot token (readable by rhnvrm for clawdbot)
  age.secrets.discord-bot-token = {
    file = ../../../secrets/discord-bot-token.age;
    owner = "rhnvrm";
    group = "users";
  };

  system.stateVersion = "24.11";
}
