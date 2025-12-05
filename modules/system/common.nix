{ lib, pkgs, ... }:
{
  # Common nix settings shared across all hosts
  nix.settings = {
    accept-flake-config = true;
    auto-optimise-store = true;
    builders-use-substitutes = true;

    # Allow your user to use substituters from flakes
    trusted-users = [ "root" "@wheel" ];

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

  # Automatic garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 30d";
  };

  # Common localization
  time.timeZone = lib.mkDefault "Asia/Kolkata";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  # Enable zsh globally
  programs.zsh.enable = true;

  # System state version
  system.stateVersion = lib.mkDefault "24.11";

  # Common activation script for system diff
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  };

  # Firmware updates
  services.fwupd.enable = lib.mkDefault true;

  # OOM Prevention
  services.earlyoom.enable = lib.mkDefault true;

  # Precompiled binaries
  programs.nix-ld.enable = lib.mkDefault true;

  # Common packages that every system should have
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    htop
    tmux
    just
    neovim
    nixfmt-rfc-style
    nixd
    nil
  ];

  # Users should not be mutable by default
  users.mutableUsers = lib.mkDefault false;

  # Security hardening
  # TODO: Verify if AppArmor should be enabled
  # Known issues: Requires reboot, may conflict with LXD/Incus containers,
  # service reload failures after nixos-rebuild (reboot fixes this)
  # security.apparmor.enable = lib.mkDefault true;
}
