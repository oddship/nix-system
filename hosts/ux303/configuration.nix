{
  modulesPath,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./disko-config.nix
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

  # Localization
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  # This laptop is a server, so we don't want it to suspend or hibernate
  services.logind = {
    settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      IdleAction = "ignore";
      HandlePowerKey = "ignore";
      HandleSuspendKey = "ignore";
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  # Users
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
  ];

  users.mutableUsers = false;

  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      git
      neovim
      zsh
      home-manager # optional, for the CLI # add to programs
    ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
    ];
  };

  # Hostname
  networking.hostName = "oddship-ux303";

  # Wifi
  age.secrets.wifi_pass_ux303.file = ../../secrets/wifi_pass_ux303.age;
  networking.wireless = {
    enable = true;
    secretsFile = config.age.secrets.wifi_pass_ux303.path;
    networks = {
      origami.pskRaw = "ext:psk_origami";
    };
  };

  programs = {
    zsh = {
      enable = true;
    };
  };

  system.stateVersion = "24.11";
}
