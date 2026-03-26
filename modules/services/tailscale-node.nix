{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-tailscale;
in
{
  options.services.rhnvrm-tailscale.enable = lib.mkEnableOption "Tailscale for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      permitCertUid = "caddy";
    };

    # Headless auth using key from agenix env file
    # Extract TAILSCALE_AUTH_KEY from the env file and use it
    systemd.services.tailscale-auth = {
      description = "Tailscale headless authentication";
      after = [
        "network-online.target"
        "tailscaled.service"
      ];
      wants = [
        "network-online.target"
        "tailscaled.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        EnvironmentFile = config.age.secrets.rhnvrm-private-env.path;
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.tailscale}/bin/tailscale up --auth-key=$TAILSCALE_AUTH_KEY --ssh'";
      };
    };
  };
}
