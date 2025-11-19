{ config, lib, pkgs, ... }:
{
  # Amp configuration
  # Note: Managing this file with Home Manager makes it read-only.
  # You won't be able to persistently change settings or permissions via the Amp CLI.
  xdg.configFile."amp/settings.json".text = builtins.toJSON {
    "amp.git.commit.ampThread.enabled" = false;
    "amp.git.commit.coauthor.enabled" = false;
    
    # Preserve existing permissions
    "amp.commands.allowlist" = [
      "just"
    ];
    "amp.permissions" = [
      {
        "tool" = "Bash";
        "matches" = {
          "cmd" = "just";
        };
        "action" = "allow";
      }
    ];
  };
}
