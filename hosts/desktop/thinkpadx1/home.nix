{
  inputs,
  lib,
  pkgs,
  gitConfigExtra ? "",
  ...
}:
{
  imports = [
    ../../../home/profiles/desktop.nix
  ];

  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  home.stateVersion = "24.11";
  # Host-specific packages (additional to desktop profile)
  home.packages = with pkgs; [
    # Only truly host-specific packages here
  ];

  # MIME apps configuration in desktop profile

  # GNOME dconf settings moved to home/profiles/desktop.nix to avoid duplication
  # Only host-specific overrides should be here

  programs.home-manager.enable = true;

  # Program configurations moved to home/profiles/desktop.nix to avoid duplication
  # Only host-specific program overrides should be here

  # Enable the system-installed update indicator for this desktop.
  dconf.settings."org/gnome/shell".enabled-extensions = lib.mkAfter [
    "nixos-updates@oddship.github.io"
  ];

  # Host-specific git config (if needed)
  programs.git.includes = [
    {
      path = gitConfigExtra; # TODO: need to figure out a better way to do this
    }
  ];
}
