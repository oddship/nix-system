{ config, lib, pkgs, ... }:
{
  users.users.rhnvrm = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    
    # Essential user packages
    packages = with pkgs; [
      git
      neovim
      zsh
      firefox
      vscode-fhs
      zed-editor
      home-manager
    ];

    # Centralized SSH key management
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
    ];
  };

  # Root user SSH access
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+77QIoFL/P784uC6KNPIjl8XQRhLKBn/wxbLZE6fIcR5HayJ0K2htzl2UdU3jPHsjRap+xkVDKCKBI16D6mT7gVabQ9J4iVR4IdYrw6KiPqamI6wdskRzf4gnaqw4+QbzUqdqlkqmqiwW29qhQ6bLi+tsU3U9uv9drWaJjQQ9ZTqlmJMmtTWwmhGb3t7VYDcBCoM4FmXGG+5v1z9fvrGN1F4hVhRuO6hydcGz7lJZBkCYRdo9NDiYZfEYqGvUbU1a8JO4EXYm4FLkyCp1t6pco9355x8ON74A4oLPqsdTBcYsP2GKThXQ3eNIzp5WAUouPC2O4Y0Go5UnHs9Yxqr5G9Hbo/K7h22T7OgrvsCOa9WjhSI83fVRblknjnkg9TT28tsR9isp9mAGMrN7Y3KaHu9QcgKdNlwzHLUcTaJi0SRHL0Kv7DTJG075i8ncG+nqwrFL7AdEz3w8dYvHihRhh8Gi5iWAot87Iq4f1j9AxpiMFmtp8U5X+LgG1et395RHuptb3viOEQrE5zfEVzto6LjbXC6NO+5HkfKJkHqcXrU46PYHq8t0EawxOa57e/0oJ0/c1F3cD4bR1CdxtGGIAy2re4p4gpAeC6V02IewKnGDwxR+/2gBG3zirs6s2Js6z4Gny3sZHDdknGwe7ghbixgzVOd7gJOYLqquDp/WRQ=="
  ];
}