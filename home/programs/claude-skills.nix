{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Claude Skills Configuration
  # ==========================
  #
  # Manages Claude Code skills using home-manager's file management.
  # Skills are stored in the nix-system repo and symlinked to ~/.claude/skills/
  #
  # To add new skills:
  # 1. Create skill directory in ~/nix-system/skills/<skill-name>/
  # 2. Add a new home.file entry below
  # 3. Run home-manager switch

  home.file.".claude/skills/tmux-orchestrator" = {
    source = ../../skills/tmux-orchestrator;
    recursive = true;
  };

  # Future skills can be added here:
  # home.file.".claude/skills/another-skill" = {
  #   source = ../../skills/another-skill;
  #   recursive = true;
  # };
}
