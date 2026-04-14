{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.s3site;
  jsonFormat = pkgs.formats.json { };
  hostedSitesConfig = jsonFormat.generate "s3site-sites.json" {
    sites = lib.mapAttrsToList (
      _: site:
      {
        hostname = site.hostname;
      }
      // lib.optionalAttrs (site.key != null) {
        key = site.key;
      }
    ) cfg.hostedSites;
  };
  controlSocketDir = builtins.dirOf cfg.controlSocket;
  dataDirManagedBySystemd = lib.hasPrefix "/var/lib/" cfg.dataDir;
  controlSocketDirManagedBySystemd = lib.hasPrefix "/run/" controlSocketDir;
  stateDirectoryName = lib.removePrefix "/var/lib/" cfg.dataDir;
  runtimeDirectoryName = lib.removePrefix "/run/" controlSocketDir;
  tailscaleAutoconnectEnabled = config.services.tailscale.enable && config.services.tailscale.authKeyFile != null;
  execArgs = [
    "${cfg.package}/bin/s3site"
    "-bucket"
    cfg.bucket
    "-region"
    cfg.region
    "-prefix"
    cfg.prefix
    "-listen"
    cfg.listen
    "-poll"
    cfg.poll
    "-storage"
    cfg.storage
    "-data-dir"
    cfg.dataDir
    "-sites-config"
    hostedSitesConfig
    "-control-socket"
    cfg.controlSocket
  ] ++ lib.optionals (cfg.endpoint != null && cfg.endpoint != "") [
    "-endpoint"
    cfg.endpoint
  ];
in
{
  options.services.s3site = {
    enable = lib.mkEnableOption "s3site hosted static site service";

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.s3site.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "s3site package to run";
    };

    bucket = lib.mkOption {
      type = lib.types.str;
      description = "S3 bucket containing hosted site tarballs";
    };

    region = lib.mkOption {
      type = lib.types.str;
      default = "us-east-1";
      description = "S3 region passed to s3site";
    };

    endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional S3-compatible endpoint URL";
    };

    prefix = lib.mkOption {
      type = lib.types.str;
      default = "sites/";
      description = "S3 key prefix for hosted site archives";
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:9001";
      description = "Local HTTP listen address for s3site";
    };

    controlSocket = lib.mkOption {
      type = lib.types.str;
      default = "/run/s3site/control.sock";
      description = "Local unix socket used for refresh operations";
    };

    poll = lib.mkOption {
      type = lib.types.str;
      default = "10m";
      description = "Polling interval for hosted site refresh checks";
    };

    storage = lib.mkOption {
      type = lib.types.enum [
        "memory"
        "disk"
      ];
      default = "disk";
      description = "s3site storage mode";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/s3site/data";
      description = "Writable directory for extracted site contents in disk mode";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional environment file with AWS_S3_ACCESS_KEY / AWS_S3_SECRET_KEY for s3site";
    };

    hostedSites = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            hostname = lib.mkOption {
              type = lib.types.str;
              description = "Hostname served by this hosted site";
            };
            key = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional explicit object key. Defaults to <prefix><hostname>.tar.gz";
            };
          };
        }
      );
      default = { };
      description = "Declared hosted sites served by s3site";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.bucket != "";
        message = "services.s3site.bucket must be set";
      }
      {
        assertion = cfg.hostedSites != { };
        message = "services.s3site.hostedSites must declare at least one site";
      }
    ];

    users.groups.s3site = { };
    users.users.s3site = {
      isSystemUser = true;
      group = "s3site";
      home = "/var/lib/s3site";
      createHome = true;
    };

    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules =
      lib.optionals (!dataDirManagedBySystemd) [
        "d ${cfg.dataDir} 0750 s3site s3site -"
      ]
      ++ lib.optionals (!controlSocketDirManagedBySystemd) [
        "d ${controlSocketDir} 0755 s3site s3site -"
      ];

    systemd.services.s3site = {
      description = "s3site hosted static site service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ] ++ lib.optionals tailscaleAutoconnectEnabled [ "tailscaled-autoconnect.service" ];
      wants = [ "network-online.target" ] ++ lib.optionals tailscaleAutoconnectEnabled [ "tailscaled-autoconnect.service" ];
      preStart = ''
        ${pkgs.coreutils}/bin/install -d -m 0750 -o s3site -g s3site ${lib.escapeShellArg cfg.dataDir}
        ${pkgs.coreutils}/bin/install -d -m 0755 -o s3site -g s3site ${lib.escapeShellArg controlSocketDir}
      '';
      serviceConfig = {
        User = "s3site";
        Group = "s3site";
        WorkingDirectory = "/var/lib/s3site";
        ExecStart = lib.escapeShellArgs execArgs;
        PermissionsStartOnly = true;
        Restart = "always";
        RestartSec = 5;
        StateDirectory = lib.mkIf dataDirManagedBySystemd stateDirectoryName;
        RuntimeDirectory = lib.mkIf controlSocketDirManagedBySystemd runtimeDirectoryName;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths =
          lib.optionals (!dataDirManagedBySystemd) [ cfg.dataDir ]
          ++ lib.optionals (!controlSocketDirManagedBySystemd) [ controlSocketDir ];
      } // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };
  };
}
