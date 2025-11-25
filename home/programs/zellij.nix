{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;

    settings = {
      # Theme and appearance
      theme = "catppuccin-mocha";
      default_mode = "normal";
      mouse_mode = true;
      pane_frames = true;
      auto_layout = true;
      session_serialization = true;

      # Disable tips and notifications on startup
      show_startup_tips = false;
      show_release_notes = false;

      # Session configuration
      default_shell = "zsh";

      # Custom keybindings for easier navigation
      keybinds = {
        normal = {
          # Alt + hjkl for pane navigation (no prefix needed)
          "bind \"Alt h\"" = {
            MoveFocus = "Left";
          };
          "bind \"Alt l\"" = {
            MoveFocus = "Right";
          };
          "bind \"Alt j\"" = {
            MoveFocus = "Down";
          };
          "bind \"Alt k\"" = {
            MoveFocus = "Up";
          };

          # Alt + n for new pane, Alt + x to close
          "bind \"Alt n\"" = {
            NewPane = { };
          };
          "bind \"Alt x\"" = {
            CloseFocus = { };
          };

          # Alt + t for new tab, Alt + w to close tab
          "bind \"Alt t\"" = {
            NewTab = { };
          };
          "bind \"Alt w\"" = {
            CloseTab = { };
          };

          # Alt + number to switch tabs
          "bind \"Alt 1\"" = {
            GoToTab = 1;
          };
          "bind \"Alt 2\"" = {
            GoToTab = 2;
          };
          "bind \"Alt 3\"" = {
            GoToTab = 3;
          };
          "bind \"Alt 4\"" = {
            GoToTab = 4;
          };
          "bind \"Alt 5\"" = {
            GoToTab = 5;
          };
        };
      };

      # UI configuration
      ui = {
        pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
      };
    };
  };
}
