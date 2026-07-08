{
  config,
  lib,
  pkgs,
  ...
}:
let
  checkpostSecret = config.age.secrets.checkpost-osquery.path;
in
{
  age.secrets.checkpost-osquery = {
    file = ../../../secrets/checkpost-osquery.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  environment.systemPackages = [ pkgs.osquery ];

  security.auditd.enable = true;

  services.osquery = {
    # Keep using the custom unit below so Checkpost values are written only at
    # activation/runtime instead of into the Nix store flagfile.
    enable = lib.mkForce false;
  };
  services.osqueryNftables.enable = true;

  systemd.services.osqueryd = {
    description = "osquery daemon";
    after = [
      "network-online.target"
      "syslog.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = ''
      set -eu

      . ${checkpostSecret}

      : "''${CHECKPOST_TLS_HOSTNAME:?missing CHECKPOST_TLS_HOSTNAME}"
      : "''${CHECKPOST_ENROLL_SECRET:?missing CHECKPOST_ENROLL_SECRET}"
      : "''${CHECKPOST_ENROLL_TLS_ENDPOINT:?missing CHECKPOST_ENROLL_TLS_ENDPOINT}"
      : "''${CHECKPOST_CONFIG_TLS_ENDPOINT:?missing CHECKPOST_CONFIG_TLS_ENDPOINT}"
      : "''${CHECKPOST_LOGGER_TLS_ENDPOINT:?missing CHECKPOST_LOGGER_TLS_ENDPOINT}"
      : "''${CHECKPOST_DISTRIBUTED_TLS_READ_ENDPOINT:?missing CHECKPOST_DISTRIBUTED_TLS_READ_ENDPOINT}"
      : "''${CHECKPOST_DISTRIBUTED_TLS_WRITE_ENDPOINT:?missing CHECKPOST_DISTRIBUTED_TLS_WRITE_ENDPOINT}"

      for name in \
        CHECKPOST_TLS_HOSTNAME \
        CHECKPOST_ENROLL_SECRET \
        CHECKPOST_ENROLL_TLS_ENDPOINT \
        CHECKPOST_CONFIG_TLS_ENDPOINT \
        CHECKPOST_LOGGER_TLS_ENDPOINT \
        CHECKPOST_DISTRIBUTED_TLS_READ_ENDPOINT \
        CHECKPOST_DISTRIBUTED_TLS_WRITE_ENDPOINT
      do
        if [ "''${!name}" = "replace-me" ]; then
          echo "$name still uses the placeholder value in ${checkpostSecret}" >&2
          exit 1
        fi
      done

      install -d -m 0750 /run/osquery
      install -d -m 0755 /etc/osquery
      printf '%s' "''${CHECKPOST_ENROLL_SECRET}" > /run/osquery/enroll_secret
      chmod 0600 /run/osquery/enroll_secret
      ln -sfn /run/osquery/enroll_secret /etc/osquery/enroll_secret

      {
        printf '%s\n' "--host_identifier=uuid"
        printf '%s\n' "--enroll_secret_path=/etc/osquery/enroll_secret"
        printf '%s\n' "--tls_server_certs=/etc/ssl/certs/ca-certificates.crt"
        printf '%s\n' "--tls_hostname=''${CHECKPOST_TLS_HOSTNAME}"
        printf '%s\n' "--enroll_tls_endpoint=''${CHECKPOST_ENROLL_TLS_ENDPOINT}"
        printf '%s\n' "--config_plugin=tls"
        printf '%s\n' "--config_tls_endpoint=''${CHECKPOST_CONFIG_TLS_ENDPOINT}"
        printf '%s\n' "--logger_plugin=tls"
        printf '%s\n' "--logger_tls_endpoint=''${CHECKPOST_LOGGER_TLS_ENDPOINT}"
        printf '%s\n' "--distributed_plugin=tls"
        printf '%s\n' "--distributed_tls_read_endpoint=''${CHECKPOST_DISTRIBUTED_TLS_READ_ENDPOINT}"
        printf '%s\n' "--distributed_tls_write_endpoint=''${CHECKPOST_DISTRIBUTED_TLS_WRITE_ENDPOINT}"
        printf '%s\n' "--logger_tls_period=''${CHECKPOST_LOGGER_TLS_PERIOD:-10}"
        printf '%s\n' "--distributed_interval=''${CHECKPOST_DISTRIBUTED_INTERVAL:-10}"
        printf '%s\n' "--disable_distributed=false"
        printf '%s\n' "--extensions_socket=/run/osquery/osquery.em"
        printf '%s\n' "--extensions_autoload=${config.services.osquery.flags.extensions_autoload}"
        printf '%s\n' "--extensions_timeout=${config.services.osquery.flags.extensions_timeout}"
      } > /run/osquery/osquery.flags
      chmod 0600 /run/osquery/osquery.flags
    '';

    serviceConfig = {
      ExecStart = "${pkgs.osquery}/bin/osqueryd --flagfile /run/osquery/osquery.flags";
      PIDFile = "/run/osquery/osqueryd.pid";
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      Environment = [ "NFT_BIN=${pkgs.nftables}/bin/nft" ];
      RuntimeDirectory = "osquery";
      RuntimeDirectoryMode = "0750";
      StateDirectory = "osquery";
      LogsDirectory = "osquery";
      Restart = "always";
    };
    path = [ pkgs.nftables ];
  };
}
