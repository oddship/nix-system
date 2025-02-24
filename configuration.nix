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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    # file-roller
    geary
    gnome-disk-utility
    # seahorse
    # sushi
    # sysprof
    #
    # gnome-shell-extensions
    #
    # adwaita-icon-theme
    # nixos-background-info
    gnome-backgrounds
    # gnome-bluetooth
    # gnome-color-manager
    # gnome-control-center
    # gnome-shell-extensions
    gnome-tour # GNOME Shell detects the .desktop file on first log-in.
    gnome-user-docs
    # glib # for gsettings program
    # gnome-menus
    # gtk3.out # for gtk-launch program
    # xdg-user-dirs # Update user dirs as described in https://freedesktop.org/wiki/Software/xdg-user-dirs/
    # xdg-user-dirs-gtk # Used to create the default bookmarks
    #
    baobab
    epiphany
    gnome-text-editor
    # gnome-calculator
    # gnome-calendar
    gnome-characters
    # gnome-clocks
    gnome-console
    # gnome-contacts
    # gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    # gnome-system-monitor
    gnome-weather
    # loupe
    # nautilus
    # gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];

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
  services.openssh.hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  services.tailscale.enable = true;

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  hardware.bluetooth.enable = true;

  # Secrets

  age.secrets.login_pass_thinkpad.file = ./secrets/login_pass_thinkpad.age;

  ################################
  # Users
  ################################
  users.mutableUsers = false;

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
      home-manager # optional, for the CLI # add to programs
    ];

    # Password
    hashedPasswordFile = config.age.secrets.login_pass_thinkpad.path;
    # password = "pass";

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

    inputs.agenix.packages.${system}.default

    nixfmt-rfc-style

    cliphist
    wl-clipboard

    syncthing

    tail-tray

    gnome-tweaks
    gnome-extension-manager
    bibata-cursors

    obsidian

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

  # TODO: move this to home manager once maybe
  # https://github.com/nix-community/home-manager/issues/2064 is resolved
  services.syncthing = {
    enable = true;
    user = "rhnvrm";
    dataDir = "/home/rhnvrm"; # TODO this can be made to come form config
    # TODO: setup the initial devices from a secrets store.
  };

  services.netbird.enable = true;

  # NixOS version. Adjust for your target release if necessary.
  system.stateVersion = "24.11";
}
