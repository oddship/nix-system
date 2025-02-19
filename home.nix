{ inputs, pkgs, ... }:
{
  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  home.stateVersion = "24.11";

  # Example: Git config
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";
  };

  # WM
  programs.kitty = {
    enable = true;
  };

  programs.ghostty = {
    enable = true;
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    font = "Noto Sans Medium 11";
  };

  # Zsh
  programs.zsh.enable = true;
}
