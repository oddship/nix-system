{ config, lib, pkgs, inputs, ... }:
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
      firefox
      chromium
      inputs.zen-browser.packages.${pkgs.system}.default

      # Editors and IDEs
      vscode-fhs
      zed-editor

      # Terminals
      kitty

      # Media
      vlc

      # Productivity
      obsidian
      ticktick
      thunderbird
      appflowy

      # Communication
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs

      # Utilities
      cliphist
      wl-clipboard
      font-manager
      pritunl-ssh
      syncthingtray-minimal
      ktailctl

      # System tools
      ncdu
      tree
      eza
      ripgrep
      fd
      bat
      age
      jq
      websocat
      zoxide
    ];
  };
}