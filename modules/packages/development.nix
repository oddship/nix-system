{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.packages.development;
in
{
  options.packages.development = {
    enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Terminal tools
      kitty
      bat # Better cat with syntax highlighting
      ncdu # NCurses disk usage analyzer
      zellij # Terminal workspace/multiplexer

      # Development tools
      nomad
      uv
      graphviz
      gh # GitHub CLI
      glab # GitLab CLI
      lazygit # Git TUI
      ast-grep # Structural search and replace
      delta # Better git diffs

      # Nix tooling
      inputs.agenix.packages.${pkgs.system}.default

      # Network tools
      nftables
      iptables
      dig # DNS lookup utility
      doggo # Modern DNS client
      inetutils # Includes telnet, ftp, ping, rsh, etc.

      # Archive tools
      zip
      unzip

      # Syncthing
      syncthing
    ];
  };
}
