{
  config,
  lib,
  pkgs,
  gitConfigExtra ? "",
  ...
}:
{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";

    delta = {
      enable = true;
      options = {
        dark = true;
        line-numbers = true;
        navigate = true;
        hyperlinks = true;
      };
    };

    aliases = {
      tree = "log --graph --oneline --all --decorate --author-date-order";
      wta = "!f() { \
        inbox_dir=\"$HOME/Documents/Code/inbox/git-worktrees\"; \
        current_dir=$(basename \"$PWD\"); \
        branch_name=\"$1\"; \
        git worktree add \"$inbox_dir/$current_dir/$branch_name\" -b \"$branch_name\"; \
      }; f";
    };

    includes = [
      {
        path = gitConfigExtra; # TODO: need to figure out a better way to do this
      }
    ];
  };
}
