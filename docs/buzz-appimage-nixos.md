---
title: Buzz AppImage on NixOS
description: Notes from making the Buzz desktop AppImage work on oddship-thinkpad-x1.
---

# Buzz AppImage on NixOS

This note records what we learned while getting the Buzz desktop AppImage
running on `oddship-thinkpad-x1`.

Community invite:
<https://oddship.communities.buzz.xyz/invite/eyJjIjoiMWZjODVkZmItNTk2YS00Yzc4LWEzMTQtMTJkNjkzOTQ0ZjY5IiwiciI6Im1lbWJlciIsImUiOjE3ODc4MjI0MTUsIm4iOiJOM0ZjS1hNLWZPWWZzYnR1Nk5PWGZnIn0.kyVFWRiBxC0D0gfGbNuCMCRdfZxp9nbdSjP2k7iwamU>

## Short version

NixOS can run AppImages through `programs.appimage`, but real desktop
AppImages often need more runtime libraries than the default `appimage-run`
environment provides.

Buzz 0.4.26 needed three layers of fixes:

1. Enable AppImage binfmt support so executable AppImages can run directly.
2. Add missing shared libraries and WebKit/Tauri desktop runtime packages to
   the AppImage FHS environment.
3. Explicitly expose GStreamer plugin paths, including `/usr/lib64`, because
   WebKit could not discover `appsrc`, `appsink`, or `autoaudiosink`.

The final implementation lives in:

- `modules/packages/appimage.nix`
- `hosts/desktop/thinkpadx1/configuration.nix`

## What failed first

After making the AppImage executable:

```bash
chmod +x Buzz_0.4.26_amd64.AppImage
./Buzz_0.4.26_amd64.AppImage
```

NixOS used `appimage-run`, unpacked the AppImage into:

```text
~/.cache/appimage-run/<sha256>
```

but Buzz failed on missing host libraries.

The first missing library was:

```text
buzz-desktop: error while loading shared libraries: libzstd.so.1:
cannot open shared object file: No such file or directory
```

Adding `pkgs.zstd` exposed the next missing library:

```text
buzz-desktop: error while loading shared libraries: libelf.so.1:
cannot open shared object file: No such file or directory
```

That came from `pkgs.elfutils`.

The important lesson: AppImages are not fully self-contained in practice. On
NixOS, the AppImage needs to run inside an FHS-like environment that contains
whatever the binary expects from a conventional Linux system.

## WebKit and Tauri runtime packages

Once the ELF libraries were available, Buzz started, generated an identity key,
started its media proxy, and began downloading speech models. At that point the
problem moved from dynamic linker failures to WebKit/GStreamer failures.

Buzz appears to be a WebKit/Tauri-style desktop app. Similar Nixpkgs packages
for Tauri/WebKit applications tend to include packages like:

- `webkitgtk_4_1`
- `libsoup_3`
- `glib-networking`
- appindicator support

Those were added to the AppImage runtime instead of installing them globally.
The point is to make `appimage-run` provide a better FHS environment without
letting random AppImage compatibility variables leak into the whole desktop
session.

## GStreamer plugin discovery

Buzz then logged:

```text
GStreamer element appsink not found. Please install it.
GStreamer element appsrc not found. Please install it
GStreamer element autoaudiosink not found. Please install it
```

With `GST_DEBUG=2`, WebKit gave clearer confirmation:

```text
no such element factory "appsrc"
no such element factory "autoaudiosink"
AudioDestinationGStreamer: Failed to create GStreamer audio sink element
```

The plugin libraries existed in the Nix store and in the generated FHS root.
For example:

```text
libgstapp.so
libgstautodetect.so
```

The catch was their location inside the `buildFHSEnv` root. On this x86_64
system, the plugins showed up under:

```text
/usr/lib64/gstreamer-1.0
```

Nixpkgs' generic FHS profile exports:

```text
/usr/lib/gstreamer-1.0
/usr/lib32/gstreamer-1.0
```

but not `/usr/lib64/gstreamer-1.0`. That meant WebKit's subprocess could not
find the plugin factories even though the packages were present.

The working fix was to wrap `appimage-run` and set both variables:

```bash
GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib64/gstreamer-1.0:/usr/lib/gstreamer-1.0:...
GST_PLUGIN_PATH=/usr/lib64/gstreamer-1.0:/usr/lib/gstreamer-1.0:...
```

The store paths are included too, but the `/usr/lib64` path is the part that
matters once execution is inside the FHS container.

## Why the wrapper matters

Setting `environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0` globally made
the value available to the desktop session, but that was too broad. It risked
affecting unrelated GTK/GStreamer applications.

The final module scopes the special GStreamer environment to AppImages by
wrapping only `appimage-run`:

```nix
package = pkgs.symlinkJoin {
  name = "appimage-run";
  paths = [ appimageRun ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/appimage-run \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 ${lib.escapeShellArg gstreamerPluginPath} \
      --set GST_PLUGIN_PATH ${lib.escapeShellArg gstreamerPluginPath}
  '';
};
```

That gives AppImages the compatibility path without changing the ambient
environment for Ghostty, Chrome, GNOME Shell, or other desktop apps.

## Ghostty interaction

While Buzz was running, launching new Ghostty windows started failing. The user
journal showed:

```text
ghostty: renderer=OpenGL
ghostty: failed to initialize surface err=error.SystemResources
ghostty: surface failed to initialize err=error.SurfaceError
```

This was not a Nix evaluation problem and did not look like a missing shared
library. It looked like Ghostty's long-lived GTK single-instance process could
not create another OpenGL surface while Buzz/WebKit was active.

The workaround was to disable Ghostty's GTK single-instance behavior:

```nix
programs.ghostty.settings = {
  gtk-single-instance = false;
};
```

That makes new Ghostty launches independent rather than depending on the
existing Ghostty process to allocate another surface.

## Useful commands

Run an AppImage directly after binfmt support is active:

```bash
./Buzz_0.4.26_amd64.AppImage
```

Bypass binfmt and force the configured wrapper:

```bash
/run/current-system/sw/bin/appimage-run ./Buzz_0.4.26_amd64.AppImage
```

Inspect GStreamer failures:

```bash
GST_DEBUG=2 ./Buzz_0.4.26_amd64.AppImage
```

Test WebKit compositing issues:

```bash
WEBKIT_DISABLE_COMPOSITING_MODE=1 ./Buzz_0.4.26_amd64.AppImage
```

Inspect Ghostty logs:

```bash
journalctl --user --since '30 minutes ago' --no-pager | rg -i 'ghostty|buzz|webkit|gstreamer|gpu|egl|glx|vulkan|wayland|gtk'
```

Check the generated AppImage wrapper:

```bash
nix build .#nixosConfigurations.oddship-thinkpad-x1.config.programs.appimage.package --no-link --print-out-paths
```

Then inspect:

```bash
sed -n '1,12p' /nix/store/...-appimage-run/bin/appimage-run
```

## Operational notes

Because this repository is a flake, imported files must be tracked by Git before
`nix flake check` can see them. A new module such as
`modules/packages/appimage.nix` must be staged with:

```bash
git add modules/packages/appimage.nix
```

before running:

```bash
just check
```

The normal apply path is:

```bash
cd /home/rhnvrm/nix-system
just check
just switch
```

If Ghostty was already running with the older configuration, stop the old
process once after switching:

```bash
pkill ghostty
```

Then launch it again from GNOME.
