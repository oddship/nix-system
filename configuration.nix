{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  nix.settings = {
    accept-flake-config = true;
    auto-optimise-store = true;
    builders-use-substitutes = true;

    experimental-features = [
      "flakes"
      "nix-command"
    ];

    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  ################################
  # Basic System Configuration
  ################################
  nixpkgs.config.allowUnfree = true;

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
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

  hardware.bluetooth.enable = true;

  ################################
  # Users
  ################################

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
  ];

  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ]; # for sudo + NM
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      neovim
      zsh
      firefox
      vscode-fhs
      home-manager # optional, for the CLI
    ];

    # Password
    password = "pass";

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
    ];
  };

  ################################
  # Home Manager Integration
  ################################

  # Configure home-manager for user rhnvrm
  home-manager.backupFileExtension = "bak";
  home-manager.users.rhnvrm = {
    imports = [
      ./home.nix
    ];
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
    kitty

    nixfmt-rfc-style

    cliphist
    wl-clipboard

    # fonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    font-manager
    font-awesome_5
    noto-fonts-emoji
    noto-fonts
    jetbrains-mono
  ];

  # NixOS version. Adjust for your target release if necessary.
  system.stateVersion = "24.11";
}
