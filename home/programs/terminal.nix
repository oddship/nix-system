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
      # Additional keybind for Claude Code
      keybind = "shift+enter=text:\\n";

      # Buzz's WebKit AppImage can make Ghostty's long-lived GTK process fail
      # new OpenGL surface creation with error.SystemResources. Keep launches
      # isolated so a new terminal does not depend on the existing instance.
      gtk-single-instance = false;
    };
  };

}
