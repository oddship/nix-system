{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.chatgpt;

  runtimeLibraries = with pkgs; [
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

  # OpenAI publishes the Linux desktop app as a Debian package. Keep the
  # version and hash pinned; update both when OpenAI publishes a new release.
  chatgpt-unwrapped = pkgs.stdenvNoCC.mkDerivation {
    pname = "chatgpt-unwrapped";
    version = "26.831.21537";

    src = pkgs.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-XBVu8qLgKRWW0HuuhmDvTwt0jfO6+Rv8ko97XjxhCxE=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.asar
      pkgs.dpkg
      pkgs.makeWrapper
    ];

    buildInputs = runtimeLibraries;

    # The Debian bundle includes optional Qt integration shims and musl
    # prebuilds alongside the glibc binaries used on NixOS.
    autoPatchelfIgnoreMissingDeps = [
      "libQt5Core.so.5"
      "libQt5Gui.so.5"
      "libQt5Widgets.so.5"
      "libQt6Core.so.6"
      "libQt6Gui.so.6"
      "libQt6Widgets.so.6"
      "libc.musl-x86_64.so.1"
    ];

    dontUnpack = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      ${pkgs.dpkg}/bin/dpkg-deb -x "$src" "$out"

      # Nix store files are immutable (0444/0555). Electron's fs.cp preserves
      # those modes when materializing bundled plugins, but Codex then rewrites
      # manifests in the staging copy. Make each copied plugin tree writable
      # before variant-specific edits run.
      asar_path="$out/usr/lib/chatgpt/resources/app.asar"
      asar_dir="$TMPDIR/chatgpt-app-asar"
      main_js="$(${pkgs.gnugrep}/bin/grep -rl \
        'async function Yi(e){let t=' "$out/usr/lib/chatgpt/resources/app.asar" 2>/dev/null | head -n 1 || true)"
      if [ -n "$main_js" ]; then
        unpacked_path="$out/usr/lib/chatgpt/resources/app.asar.unpacked"
        unpacked_backup="$TMPDIR/chatgpt-app-asar.unpacked"
        if [ -d "$unpacked_path" ]; then
          rm -rf "$unpacked_backup"
          cp -a "$unpacked_path" "$unpacked_backup"
        fi

        ${pkgs.asar}/bin/asar extract "$asar_path" "$asar_dir"
        main_js="$(${pkgs.gnugrep}/bin/grep -rl \
          'async function Yi(e){let t=' "$asar_dir/.vite/build" | head -n 1)"
        substituteInPlace "$main_js" --replace-fail \
          'async function Yi(e){let t=' \
          'async function Wi(e){let t=await y.default.readdir(e,{withFileTypes:!0});await y.default.chmod(e,448),await Promise.all(t.map(t=>{let n=(0,p.join)(e,t.name);return t.isDirectory()?Wi(n):y.default.chmod(n,384)}))}async function Yi(e){await Wi(e.pluginRoot);let t='
        ${pkgs.asar}/bin/asar pack "$asar_dir" "$asar_path"

        if [ -d "$unpacked_backup" ]; then
          rm -rf "$unpacked_path"
          cp -a "$unpacked_backup" "$unpacked_path"
        fi
      fi

      install -Dm644 "$out/usr/share/applications/chatgpt.desktop" \
        "$out/share/applications/chatgpt.desktop"
      install -Dm644 "$out/usr/share/pixmaps/chatgpt.png" \
        "$out/share/pixmaps/chatgpt.png"
      mkdir -p "$out/bin"
      ln -s "$out/usr/bin/chatgpt" "$out/bin/chatgpt"
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram "$out/usr/lib/chatgpt/ChatGPT" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"
    '';

    meta = {
      description = "ChatGPT desktop app by OpenAI (unwrapped Debian package)";
      homepage = "https://developers.openai.com/codex/app";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
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

    environment.systemPackages = [ chatgpt-unwrapped ];
  };
}
