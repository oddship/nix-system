{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Kitty terminal
  programs.kitty = {
    enable = true;
  };

  # Ghostty terminal
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "catppuccin-mocha";
      # Additional keybind for Claude Code
      keybind = "shift+enter=text:\\n";
    };
  };

  # Rofi launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Noto Sans Medium 11";
  };
}
