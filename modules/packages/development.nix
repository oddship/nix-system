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

      # Development tools
      nomad
      uv
      graphviz
      gh # GitHub CLI
      glab # GitLab CLI

      # Nix tooling
      inputs.agenix.packages.${pkgs.system}.default

      # Network tools
      nftables
      iptables

      # Syncthing
      syncthing
    ];
  };
}
