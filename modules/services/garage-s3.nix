{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-garage;
in
{
  options.services.rhnvrm-garage.enable = lib.mkEnableOption "Garage S3 for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.garage = {
      package = pkgs.garage;
      enable = true;
      settings = {
        metadata_dir = "/var/lib/garage/meta";
        data_dir = "/var/lib/garage/data";
        rpc_bind_addr = "[::]:3901";
        replication_mode = "none";
        # rpc_secret loaded from env file via systemd
        s3_api = {
          api_bind_addr = "[::]:3900";
          s3_region = "garage";
        };
      };
    };

    # Inject RPC secret from single env file
    systemd.services.garage.serviceConfig.EnvironmentFile = config.age.secrets.rhnvrm-private-env.path;
    # Garage reads GARAGE_RPC_SECRET from env if rpc_secret not in config

    environment.systemPackages = [ pkgs.garage ]; # CLI for bootstrap
  };
}
