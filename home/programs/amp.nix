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

  xdg.configFile."amp/AGENTS.md".text = ''
    ## Git Commit Guidelines

    - Don't include any coauthors and specifically avoid adding "Co-Authored-By" lines
    - By default, include the prompts used to create the commit in quotes when creating a git commit
    - Before doing the git commit, look at the last few commits in full, and try to match the style

    ## Writing Style

    - Dont use emdashes or dashes when asking to write like me
    - Form simple sentences dont make overly complex sentences
  '';
}
