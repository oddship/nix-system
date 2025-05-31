{ config, lib, pkgs, inputs, ... }:
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
      
      # Development tools
      nomad
      uv

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