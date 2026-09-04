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
    version = "26.901.20858";

    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-QqZHfyL0E21iMh7ae0aXp52h62bWHcuFqwQghgoaUiM=";
    };

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.python3
    ];

    dontUnpack = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      ${pkgs.dpkg}/bin/dpkg-deb -x "$src" "$out"
      # fs.cp preserves the Nix store's read-only modes. The app edits plugin
      # manifests in its staging copy, so make that copy owner-writable first.
      # Patch only the archive entry; preserve native modules and unpack flags.
      ${pkgs.python3}/bin/python3 ${./chatgpt-plugin-permissions.py} \
        "$out/usr/lib/chatgpt/resources/app.asar"
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

    targetPkgs =
      pkgs: with pkgs; [
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
        # ANGLE loads libGL.so.1 dynamically.
        libglvnd
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

    runScript = pkgs.writeShellScript "chatgpt-wayland" ''
      export NIXOS_OZONE_WL=1
      exec ${chatgpt-unwrapped}/usr/bin/chatgpt --ozone-platform=wayland "$@"
    '';

    extraInstallCommands = ''
      install -Dm644 ${chatgpt-unwrapped}/usr/share/applications/chatgpt.desktop \
        $out/share/applications/chatgpt.desktop
      install -Dm644 ${chatgpt-unwrapped}/usr/share/pixmaps/chatgpt.png \
        $out/share/pixmaps/chatgpt.png
    '';

    meta = {
      description = "ChatGPT desktop app with Codex for Linux";
      homepage = "https://developers.openai.com/codex/app";
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
