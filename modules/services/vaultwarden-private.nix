{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-vaultwarden;
in
{
  options.services.rhnvrm-vaultwarden.enable = lib.mkEnableOption "Vaultwarden for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        SIGNUPS_ALLOWED = false;
        WEBSOCKET_ENABLED = true;
        DATA_FOLDER = "/var/lib/vaultwarden";
      };
      environmentFile = config.age.secrets.rhnvrm-private-env.path;
      # Env file has ADMIN_TOKEN=...
    };
  };
}
