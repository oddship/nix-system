{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-caddy-tailscale;

  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      tailscale {
        auth_key {$TS_AUTHKEY}
        state_dir /var/lib/caddy/tailscale
      }
      auto_https off
    }

    :80 {
      bind tailscale/gitea
      reverse_proxy localhost:3000
    }

    :80 {
      bind tailscale/vault
      reverse_proxy localhost:8222
    }

    :80 {
      bind tailscale/s3
      reverse_proxy localhost:3900
    }

    :80 {
      bind tailscale/dash
      reverse_proxy localhost:5173
    }

    :80 {
      bind tailscale/term
      reverse_proxy localhost:7681
    }
  '';
in
{
  options.services.rhnvrm-caddy-tailscale.enable = lib.mkEnableOption "Caddy with Tailscale for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy-with-tailscale;
      configFile = caddyfile;
    };

    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = config.age.secrets.rhnvrm-private-env.path;
      ReadWritePaths = [ "/var/lib/caddy" ];
    };
  };
}
