{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.packages.desktop;
in
{
  options.packages.desktop = {
    enable = lib.mkEnableOption "desktop applications";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Browsers
      chromium
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Productivity
      obsidian
      ticktick

      # Utilities
      cliphist
      wl-clipboard
      pritunl-ssh
      syncthingtray-minimal
      gnomeExtensions.tailscale-qs
      font-manager
      file
      imagemagick
      psmisc # provides killall, fuser, pstree
    ];
  };
}
