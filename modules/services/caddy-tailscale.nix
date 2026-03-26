{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-caddy-tailscale;
in
{
  options.services.rhnvrm-caddy-tailscale.enable = lib.mkEnableOption "Caddy with Tailscale for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy-with-tailscale; # From overlay in flake.nix

      # caddy-tailscale: each "bind tailscale/<name>" creates a Tailscale node
      # Site address uses :443 since caddy-tailscale handles TLS via Tailscale certs
      globalConfig = ''
        tailscale {
          auth_key {$TS_AUTHKEY}
          state_dir /var/lib/caddy/tailscale
        }
      '';

      virtualHosts = {
        # Each site binds to its own Tailscale identity
        ":443" = {
          extraConfig = ''
            bind tailscale/gitea
            reverse_proxy localhost:3000
          '';
        };
        "vault.localhost:443" = {
          extraConfig = ''
            bind tailscale/vault
            reverse_proxy localhost:8222
          '';
        };
        "s3.localhost:443" = {
          extraConfig = ''
            bind tailscale/s3
            reverse_proxy localhost:3900
          '';
        };
        "dash.localhost:443" = {
          extraConfig = ''
            bind tailscale/dash
            reverse_proxy localhost:5173
          '';
        };
        "term.localhost:443" = {
          extraConfig = ''
            bind tailscale/term
            reverse_proxy localhost:7681
          '';
        };
      };
    };

    # Inject TS_AUTHKEY from env file
    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = config.age.secrets.rhnvrm-private-env.path;
      ReadWritePaths = [ "/var/lib/caddy" ];
    };
  };
}
