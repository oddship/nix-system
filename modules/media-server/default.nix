{
  pkgs,
  config,
  lib,
  ...
}:
let
  mediaDir = "/var/lib/media";
  mediaGroup = "media";

  transmissionPort = 9091;
  domain = "oddship.rohanverma.net"; # TODO: this can be made an option?

  cfg = config.media_server;
in
{
  options = {
    media_server.enable = lib.mkEnableOption "Serve and store media from this machine";
    media_server.cloudflare_secret = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Cloudflare secret for Tunnel";
    };
    media_server.export_metrics = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Export Prometheus metrics from media services";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${mediaGroup} = { };
    users.users = {
      ${mediaGroup} = {
        isSystemUser = true;
        group = mediaGroup;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${mediaDir} 0775 root ${mediaGroup} -"
      "d ${mediaDir}/torrents 0775 ${mediaGroup} ${mediaGroup} -"
      "d ${mediaDir}/torrents/.incomplete 0775 ${mediaGroup} ${mediaGroup} -"
      "d ${mediaDir}/torrents/.watch 0775 ${mediaGroup} ${mediaGroup} -"
    ];

    services.cloudflared = {
      enable = true;
      tunnels = {
        "d7c54240-62c3-4513-b662-709338cc913f" = {
          # credentialsFile = "${cfg.cloudflare_secret}";
          ingress = {
            "jellyfin.${domain}" = {
              service = "http://localhost:8096";
            };
            "transmission.${domain}" = {
              service = "http://localhost:9091";
            };
          };
          default = "http_status:404";
        };
      };
    };

    # services.nginx = {
    #   enable = true;
    #   virtualHosts = {
    #     "jellyfin.${domain}" = {
    #       serverName = "jellyfin.${domain}";
    #       locations."/" = {
    #         proxyWebsockets = true;
    #         proxyPass = "http://localhost:8096/";
    #       };
    #     };

    #     "transmission.${domain}" = {
    #       serverName = "transmission.${domain}";
    #       locations."/" = {
    #         proxyWebsockets = true;
    #         proxyPass = "http://localhost:9091/"; # TODO: needs to be coming from above config
    #       };
    #     };
    #   };
    # };

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };
    services.radarr = {
      enable = true;
      group = mediaGroup;
      openFirewall = true;
    };
    services.sonarr = {
      enable = true;
      group = mediaGroup;
      openFirewall = true;
    };
    services.bazarr = {
      enable = true;
      group = mediaGroup;
      openFirewall = true;
    };
    services.transmission = {
      enable = true;
      group = mediaGroup;
      openFirewall = true;
      openRPCPort = true;
      openPeerPorts = true;
      settings = {
        download-dir = "${mediaDir}/torrents";
        incomplete-dir-enabled = true;
        incomplete-dir = "${mediaDir}/torrents/.incomplete";
        watch-dir-enabled = true;
        watch-dir = "${mediaDir}/torrents/.watch";
        rpc-port = transmissionPort;
        rpc-whitelist-enabled = true;
        rpc-authentication-required = false;
        blocklist-enabled = true;
        blocklist-url = "https://github.com/Naunter/BT_BlockLists/raw/master/bt_blocklists.gz";
        utp-enabled = true;
        encryption = 1;
        port-forwarding-enabled = false;
        download-queue-size = 10;
        cache-size-mb = 50;
        ratio-limit-enabled = true;
      };
    };
  };
}
