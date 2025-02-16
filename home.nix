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

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "waybar"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      "$mod" = "SUPER";

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      bind =
        [
          "$mod, RETURN, exec, kitty"
          "$mod, Q, killactive"
          "$mod SHIFT, Q, exit"
          # "$mod R, exec, anyrun"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
              "$mod, ${ws}, workspace, ${toString (x + 1)}"
              "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            ]
          ) 10
        ));

      monitor = [ ",preferred,auto,1" ];
    };
  };

  # Zsh
  programs.zsh.enable = true;

  programs.waybar = {
    enable = true;
  };
}
