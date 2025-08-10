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
      inputs.zen-browser.packages.${pkgs.system}.default

      # Productivity
      obsidian
      ticktick

      # Communication
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs

      # Utilities
      cliphist
      wl-clipboard
      pritunl-ssh
      syncthingtray-minimal
      ktailctl
      font-manager
      file
      imagemagick
    ];
  };
}
