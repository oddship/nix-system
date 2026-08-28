{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.chatgpt;

  # OpenAI publishes the Linux desktop app as a Debian package. Keep the
  # version and hash pinned; update both when OpenAI publishes a new release.
  chatgpt-unwrapped = pkgs.stdenvNoCC.mkDerivation {
    pname = "chatgpt-unwrapped";
    version = "26.825.31414";

    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-wXMEi6gPevnNiQT5ofJyr/SUejFPb+l9obuDaEds3Pk=";
    };

    nativeBuildInputs = [ pkgs.dpkg ];

    dontUnpack = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      ${pkgs.dpkg}/bin/dpkg-deb -x "$src" "$out"
      runHook postInstall
    '';

    meta = {
      description = "ChatGPT desktop app by OpenAI (unwrapped Debian package)";
      homepage = "https://developers.openai.com/codex/app";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  };

  chatgpt = pkgs.buildFHSEnv {
    name = "chatgpt";

    targetPkgs = pkgs: with pkgs; [
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libnotify
      libpulseaudio
      libusb1
      libx11
      libxcb
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxkbcommon
      libxrandr
      libgbm
      mesa
      nspr
      nss
      pango
      systemd
      vulkan-loader
      xdg-utils
      xz
    ];

    runScript = "${chatgpt-unwrapped}/usr/bin/chatgpt";

    extraInstallCommands = ''
      install -Dm644 ${chatgpt-unwrapped}/usr/share/applications/chatgpt.desktop \
        $out/share/applications/chatgpt.desktop
      install -Dm644 ${chatgpt-unwrapped}/usr/share/pixmaps/chatgpt.png \
        $out/share/pixmaps/chatgpt.png
    '';

    meta = {
      description = "ChatGPT desktop app with Codex for Linux";
      homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      mainProgram = "chatgpt";
    };
  };
in
{
  options.packages.chatgpt = {
    enable = lib.mkEnableOption "ChatGPT desktop app with Codex";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        message = "packages.chatgpt currently supports only x86_64-linux.";
      }
    ];

    environment.systemPackages = [ chatgpt ];
  };
}
