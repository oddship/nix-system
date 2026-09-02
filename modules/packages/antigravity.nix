{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.packages.antigravity;
in
{
  options.packages.antigravity = {
    enable = lib.mkEnableOption "Google Antigravity desktop app";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      # Antigravity 2.0 Base App
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Antigravity IDE
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide

      # Antigravity CLI (`agy`)
      inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
    ];
  };
}
