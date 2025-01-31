{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan
      ./hardware-configuration.nix
    ];

  ################################
  # Basic System Configuration
  ################################

  # Hostname
  networking.hostName = "oddship-thinkpad-x1";

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Localization
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  programs.zsh.enable = true;

  ################################
  # Desktop Environment
  ################################

  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.displayManager.sddm.enable = true;


  ################################
  # Various Services
  ################################

  # Sound with Pipewire
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Touchpad support
  services.libinput.enable = true;

  # OpenSSH
  services.openssh.enable = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ################################
  # Users
  ################################

  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # for sudo + NM
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      neovim
      zsh
      home-manager  # optional, for the CLI
    ];
  };

  ################################
  # Home Manager Integration
  ################################

  # Configure home-manager for user rhnvrm
  home-manager.users.rhnvrm = { pkgs, ... }: {
    home.username = "rhnvrm";
    home.homeDirectory = "/home/rhnvrm";

    home.stateVersion = "24.11";

    # Example: Git config
    programs.git = {
      enable = true;
      userName = "Rohan Verma";
      userEmail = "hello@rohanverma.net";
    };

    # Zsh
    programs.zsh.enable = true;
  };

  ################################
  # System Packages
  ################################

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    zsh
    neovim
    tmux
    htop
    curl
  ];

  # NixOS version. Adjust for your target release if necessary.
  system.stateVersion = "24.11";
}

