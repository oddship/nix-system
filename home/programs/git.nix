{ config, lib, pkgs, gitConfigExtra ? "", ... }:
{
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Rohan Verma";
    userEmail = "hello@rohanverma.net";

    includes = [
      {
        path = gitConfigExtra; # TODO: need to figure out a better way to do this
      }
    ];
  };
}