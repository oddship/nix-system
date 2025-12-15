{ config, lib, pkgs, ... }:
let
  cfg = config.services.server;
in
{
  options.services.server = {
    enable = lib.mkEnableOption "server services";

    webserver.enable = lib.mkEnableOption "Caddy web server";
    webserver.email = lib.mkOption {
      type = lib.types.str;
      default = "hello@rohanverma.net";
    };

    staticSites = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            domain = lib.mkOption { type = lib.types.str; };
            root = lib.mkOption {
              type = lib.types.package;
              description = "Nix derivation containing the static site";
            };
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = lib.mkIf cfg.webserver.enable {
      enable = true;
      email = cfg.webserver.email;

      # Generate both HTTP and HTTPS hosts for each site
      # HTTP is needed because Cloudflare proxy sends HTTP to origin
      virtualHosts = lib.foldl' (acc: item: acc // item) {} (
        lib.mapAttrsToList (
          name: site:
          let
            commonConfig = ''
              root * ${site.root}
              file_server
              encode gzip
            '';
          in {
            # HTTPS host with TLS
            "${site.domain}" = {
              extraConfig = ''
                ${commonConfig}

                # DNS-01 challenge for Let's Encrypt behind Cloudflare proxy
                tls {
                  dns cloudflare {env.CLOUDFLARE_DNS_API_TOKEN}
                }
              '';
            };
            # HTTP host (for Cloudflare proxy origin requests)
            "http://${site.domain}" = {
              extraConfig = commonConfig;
            };
          }
        ) cfg.staticSites
      );
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
