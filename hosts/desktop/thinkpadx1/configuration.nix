{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Hardware configuration
    ./hardware-configuration.nix
    ./disko-config.nix
    ./flatpaks.nix

    # System modules
    ../../../modules/system/common.nix
    ../../../modules/system/boot.nix
    ../../../modules/system/networking.nix

    # User management
    ../../../modules/users/rhnvrm.nix

    # Services
    ../../../modules/services/openssh.nix
    ../../../modules/services/desktop.nix
    ../../../modules/services/development.nix

    # Desktop environment
    ../../../modules/desktop/gnome.nix

    # Package collections
    ../../../modules/packages/desktop.nix
    ../../../modules/packages/development.nix
    ../../../modules/packages/scripts.nix
    ../../../modules/packages/libreoffice.nix

  ];

  # Host-specific configuration
  networking.hostName = "oddship-thinkpad-x1";

  # Enable modules for this host
  services.desktop.enable = true;
  services.development = {
    enable = true;
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    gaming.enable = true;
  };
  desktop.gnome.enable = true;
  packages.desktop.enable = true;
  packages.development.enable = true;
  packages.scripts.enable = true;
  packages.libreoffice.enable = true;

  # Desktop-specific user configuration
  users.users.rhnvrm.extraGroups = [ "docker" ];

  # Secrets management
  age.secrets.login_pass_thinkpad.file = ../../../secrets/login_pass_thinkpad.age;
  age.secrets.git-config-extra = {
    file = ../../../secrets/git-config-extra.age;
    owner = "rhnvrm";
  };

  # Set user password from secret
  users.users.rhnvrm.hashedPasswordFile = config.age.secrets.login_pass_thinkpad.path;

  # Home Manager integration
  home-manager = {
    backupFileExtension = "bak";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.rhnvrm = {
      imports = [ ./home.nix ];
      _module.args = {
        gitConfigExtra = config.age.secrets.git-config-extra.path;
      };
    };
  };

  # Host-specific packages that don't belong in modules
  environment.systemPackages = with pkgs; [
    # Empty - all packages are in modules
  ];
}
