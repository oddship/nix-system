{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.packages.chatgpt;
in
{
  imports = [ inputs.chatgpt-desktop.nixosModules.default ];

  options.packages.chatgpt.enable = lib.mkEnableOption "ChatGPT desktop app with Codex";

  config = lib.mkIf cfg.enable {
    programs.chatgpt-desktop = {
      enable = true;
      primaryRuntime.enable = true;
    };
  };
}
