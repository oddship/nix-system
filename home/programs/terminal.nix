{ config, lib, pkgs, ... }:
{
  # Kitty terminal
  programs.kitty = {
    enable = true;
  };

  # Ghostty terminal
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };

  # Rofi launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Noto Sans Medium 11";
  };
}