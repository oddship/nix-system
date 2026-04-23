# modules

Reusable NixOS modules live here. The layout is intentionally boring: group
modules by what they configure, keep shared logic out of host files, and only
push things into a module when there is a real reuse or abstraction boundary.

## Directory map

### `system/`

Shared system-level defaults.

- `common.nix` — base Nix settings, locale/timezone, common packages, and other
  machine-wide defaults
- `boot.nix` — bootloader and boot-time defaults
- `networking.nix` — NetworkManager, nftables, Avahi, and resolver setup

### `desktop/`

Desktop environment modules.

- `gnome.nix` — GNOME session, fonts, desktop defaults, and related packages

### `services/`

Service modules range from general workstation services to host-specific server
building blocks.

- `openssh.nix` — small SSH baseline
- `desktop.nix` — PipeWire, Tailscale operator setup, Netbird, Syncthing, and
  printing
- `development.nix` — Docker, Steam, libvirt/Podman toggles, lorri, direnv,
  Android tools, and similar host services
- `server.nix` — public Caddy wrapper for static sites and reverse proxies
- `s3site.nix` — service wrapper around the `s3site` binary and its hosted-site
  config
- `tailscale-node.nix` — headless Tailscale auth for `rhnvrm-private`
- `garage-s3.nix` — Garage S3 service for the private box
- `gitea-private.nix` — internal Gitea instance
- `vaultwarden-private.nix` — internal Vaultwarden instance
- `caddy-tailscale.nix` — Tailscale-authenticated Caddy front door for private
  services
- `web-terminal.nix` — `ttyd`-based web terminal

### `packages/`

System package groups.

- `desktop.nix` — GUI apps for the workstation
- `development.nix` — CLI/dev packages and a few repo-specific tools
- `libreoffice.nix` — LibreOffice bundle behind its own flag
- `scripts.nix` — wraps the repo's shell helpers into installable commands

### `users/`

- `rhnvrm.nix` — base user account definition and common account-level packages

### `hardware/`

- `laptop.nix` — currently a placeholder for laptop-specific shared hardware
  behavior

## How current hosts compose these modules

A few examples from the live host set:

- `oddship-thinkpad-x1` pulls in the shared system modules, the GNOME module,
  the user module, desktop services, development services, and package groups
- `oddship-web` stays much thinner and mainly uses `services/server.nix` plus
  `services/s3site.nix`, with host-local config for Linkpage and Umami
- `rhnvrm-private` composes several service modules from `modules/services/`
  because that host is mostly a private-service box

## Conventions

This repo is not trying to invent a framework on top of NixOS modules. The
conventions are simple:

- keep options under a sensible namespace like `services.foo` or `packages.bar`
- gate optional behavior with `mkEnableOption`
- keep shared behavior in modules and host-specific values in `hosts/`
- avoid extracting a module until there is an actual reuse or readability win

If a host only needs something once, keeping it in the host file is still fine.
