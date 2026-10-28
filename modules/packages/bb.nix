{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.bb;
  pname = "bb";
  version = "0.47.1";
  src = pkgs.fetchurl {
    url = "https://github.com/get-bb/bb/releases/download/desktop-v${version}/bb-${version}-x86_64.AppImage";
    hash = "sha256-rECk/fmgZf8SfTnD+DlK7S4ceZgbnxukFt172XF10sA=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
  # Run on the host: wrapType2's Bubblewrap environment prevents child
  # processes (including agent terminals) from using sudo or pkexec.
  package = pkgs.stdenv.mkDerivation {
    inherit pname version;
    src = appimageContents;
    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];
    buildInputs = with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libgbm
      libsecret
      libxkbcommon
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      systemd
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxscrnsaver
      libxtst
    ];
    runtimeDependencies = map lib.getLib [
      pkgs.libnotify
      pkgs.libappindicator-gtk3
    ];
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/${pname} $out/bin
      cp -a . $out/lib/${pname}/
      rm -rf $out/lib/${pname}/usr/lib
      # NixOS uses glibc; these optional musl builds cannot be loaded here.
      rm -f $out/lib/${pname}/resources/app.asar.unpacked/node_modules/better-sqlite3/prebuilds/linuxmusl-*.node
      rm -rf $out/lib/${pname}/resources/app.asar.unpacked/node_modules/@parcel/watcher-linux-*-musl

      makeWrapper $out/lib/${pname}/bb $out/bin/bb \
        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib

      install -Dm644 bb.desktop $out/share/applications/bb.desktop
      substituteInPlace $out/share/applications/bb.desktop \
        --replace-fail "Exec=AppRun" "Exec=bb"
      cp -r usr/share/icons $out/share/
      runHook postInstall
    '';
    meta = {
      description = "bb agentic IDE";
      homepage = "https://getbb.app";
      license = lib.licenses.mit;
      platforms = [ "x86_64-linux" ];
      mainProgram = pname;
    };
  };
in
{
  options.packages.bb.enable = lib.mkEnableOption "bb desktop app";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ package ];
  };
}
