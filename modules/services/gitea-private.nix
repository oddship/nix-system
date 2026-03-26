{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-gitea;
in
{
  options.services.rhnvrm-gitea.enable = lib.mkEnableOption "Gitea for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      database.type = "sqlite3";
      lfs.enable = true;
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };
        service.DISABLE_REGISTRATION = false; # Change to true after initial setup
        actions.ENABLED = true;
      };
    };

    # Gitea Actions runner — enable AFTER first boot
    # 1. Log into Gitea, go to Site Administration > Runners
    # 2. Generate a registration token
    # 3. Add tokenFile and uncomment this block, then nixos-rebuild switch
    #
    # services.gitea-actions-runner.instances.default = {
    #   enable = true;
    #   name = "rhnvrm-private-runner";
    #   url = "http://127.0.0.1:3000";
    #   tokenFile = "/var/lib/gitea-runner/token";
    #   labels = [ "native:host" ];  # Use native host, no docker needed
    # };

    networking.firewall.allowedTCPPorts = [ 2222 ];
  };
}
