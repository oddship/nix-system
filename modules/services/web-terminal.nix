{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-web-terminal;
in
{
  options.services.rhnvrm-web-terminal.enable = lib.mkEnableOption "Web terminal for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    systemd.services.web-terminal = {
      description = "Web terminal via ttyd";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.ttyd}/bin/ttyd -p 7681 -W ${pkgs.tmux}/bin/tmux new -A -s server";
        User = "rhnvrm";
        Restart = "always";
      };
    };
  };
}
