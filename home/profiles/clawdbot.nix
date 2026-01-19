{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../programs/shell.nix
    ../programs/git.nix
  ];

  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  # Install clawdbot CLI
  home.packages = [ pkgs.clawdbot ];

  # Systemd user service for clawdbot gateway
  # Config is managed via CLI, not nix
  systemd.user.services.clawdbot-gateway = {
    Unit = {
      Description = "Clawdbot gateway";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.clawdbot}/bin/clawdbot gateway";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.stateVersion = "24.11";
}
