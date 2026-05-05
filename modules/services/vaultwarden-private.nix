{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.rhnvrm-vaultwarden;

  # Nixpkgs is still on Vaultwarden 1.35.7, so pin this host to 1.35.8.
  vaultwardenVersion = "1.35.8";
  webVaultVersion = "2026.3.1+0";

  vaultwardenWebVault = pkgs.buildNpmPackage rec {
    pname = "vaultwarden-webvault";
    version = webVaultVersion;

    src = pkgs.fetchFromGitHub {
      owner = "vaultwarden";
      repo = "vw_web_builds";
      tag = "v${version}";
      hash = "sha256-nUhSoqf655eOs+rKqAZB0XzPD6ePL6CIxVAnB5dmJAs=";
    };

    npmDepsHash = "sha256-dlYN2aiv6XbDXQVstfI6XIe+X5Q1lqs62eNalGTGx7k=";

    nativeBuildInputs = [
      pkgs.python3
      pkgs.dart-sass
    ];

    makeCacheWritable = true;

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      npm_config_build_from_source = "true";
    };

    preBuild = ''
      echo "export const compilerCommand = ['dart-sass'];" > node_modules/sass-embedded/dist/lib/src/compiler-path.js
    '';

    npmRebuildFlags = [
      # FIXME one of the esbuild versions fails to download @esbuild/linux-x64
      "--ignore-scripts"
    ];

    npmBuildScript = "dist:oss:selfhost";

    npmBuildFlags = [
      "--workspace"
      "apps/web"
    ];

    npmFlags = [ "--legacy-peer-deps" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/vaultwarden
      mv apps/web/build $out/share/vaultwarden/vault
      runHook postInstall
    '';

    meta = {
      description = "Integrates the web vault into vaultwarden";
      homepage = "https://github.com/vaultwarden/vw_web_builds";
      platforms = lib.platforms.all;
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [
        dotlambda
        SuperSandro2000
      ];
    };
  };

  mkVaultwardenPackage =
    {
      dbBackend ? "sqlite",
    }:
    pkgs.rustPlatform.buildRustPackage (finalAttrs: {
      pname = "vaultwarden";
      version = vaultwardenVersion;

      src = pkgs.fetchFromGitHub {
        owner = "dani-garcia";
        repo = "vaultwarden";
        tag = finalAttrs.version;
        hash = "sha256-bEPwH0+b4cQTh1hNiiX2qvTNeRxxShm2JXNKNfn4xm8=";
      };

      cargoHash = "sha256-gcE3qfSVCk08haADyqOff4R0ekd9Q6RB59LUtow9Yi4=";

      # used for "Server Installed" version in admin panel
      env.VW_VERSION = finalAttrs.version;

      nativeBuildInputs = [ pkgs.pkg-config ];

      buildInputs = [
        pkgs.openssl
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.libiconv ]
      ++ lib.optional (dbBackend == "mysql") pkgs.libmysqlclient
      ++ lib.optional (dbBackend == "postgresql") pkgs.libpq;

      buildFeatures = dbBackend;

      passthru = {
        webvault = vaultwardenWebVault;
      };

      meta = {
        description = "Unofficial Bitwarden compatible server written in Rust";
        homepage = "https://github.com/dani-garcia/vaultwarden";
        changelog = "https://github.com/dani-garcia/vaultwarden/releases/tag/${finalAttrs.version}";
        license = lib.licenses.agpl3Only;
        maintainers = with lib.maintainers; [
          dotlambda
          SuperSandro2000
        ];
        mainProgram = "vaultwarden";
      };
    });

  vaultwardenPackage = lib.makeOverridable mkVaultwardenPackage { };
in
{
  options.services.rhnvrm-vaultwarden.enable = lib.mkEnableOption "Vaultwarden for rhnvrm-private";

  config = lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      package = vaultwardenPackage;
      webVaultPackage = vaultwardenWebVault;
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
