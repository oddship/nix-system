{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.appimage;

  # Keep AppImage WebKit/Tauri apps usable on NixOS. Buzz 0.4.26 exposed the
  # specific gaps this covers: libzstd, libelf, WebKitGTK runtime libraries, and
  # GStreamer plugins for appsrc/appsink/autoaudiosink.
  gstreamerPackages = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];

  # buildFHSEnv exposes GStreamer plugins under /usr/lib64 on x86_64, but its
  # default profile only adds /usr/lib and /usr/lib32. Add lib64 explicitly so
  # WebKitWebProcess can discover plugins when launched from an AppImage.
  fhsGstreamerPluginPath = "/usr/lib64/gstreamer-1.0:/usr/lib/gstreamer-1.0";
  gstreamerPluginPath =
    fhsGstreamerPluginPath + ":" + lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstreamerPackages;

  appimageRun = pkgs.appimage-run.override {
    extraPkgs =
      pkgs:
      [
        pkgs.elfutils
        pkgs.ffmpeg
        pkgs.glib-networking
        pkgs.imagemagick
        pkgs.libayatana-appindicator
        pkgs.libsoup_3
        pkgs.webkitgtk_4_1
        pkgs.zstd
      ]
      ++ gstreamerPackages;
  };
in
{
  options.packages.appimage = {
    enable = lib.mkEnableOption "AppImage support";
  };

  config = lib.mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.symlinkJoin {
        name = "appimage-run";
        paths = [ appimageRun ];
        meta.mainProgram = "appimage-run";
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/appimage-run \
            --set GST_PLUGIN_SYSTEM_PATH_1_0 ${lib.escapeShellArg gstreamerPluginPath} \
            --set GST_PLUGIN_PATH ${lib.escapeShellArg gstreamerPluginPath}
        '';
      };
    };
  };
}
