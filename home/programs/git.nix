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

    includes = [
      {
        path = gitConfigExtra; # TODO: need to figure out a better way to do this
      }
    ];
  };
}
