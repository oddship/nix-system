# nix-system

Personal NixOS repo for my laptops, desktop setup, and small Hetzner-hosted
services. It keeps the system builds, Home Manager config, agenix secrets,
helper scripts, and the minimum OpenTofu needed to bootstrap and redeploy the
machines I actually run.

The repo-local READMEs are still the main map of the tree. The `docs/`
directory is the smaller published subset, built as a GitHub Pages site with
[moat](https://github.com/oddship/moat).

## Current hosts

| Host | Role | Notes |
| --- | --- | --- |
| `oddship-thinkpad-x1` | workstation | Main desktop/laptop setup with GNOME, Home Manager, development tools, and the full personal shell/editor stack. |
| `oddship-ux303` | laptop server | Repurposed laptop host. Wi-Fi stays enabled and lid suspend is disabled so it can sit around as a small server. |
| `oddship-beagle` | minimal server | Small baseline NixOS box with SSH and the shared user setup. |
| `oddship-web` | public web host | Hetzner VM running Caddy, Umami, two Linkpage instances, and `s3site` for hosted static sites. |
| `rhnvrm-private` | private services host | Hetzner VM for Garage S3, Gitea, Vaultwarden, a web terminal, and Tailscale-only internal access. |

The authoritative host list lives in `flake.nix`.

## Repo layout

- `flake.nix` — system definitions, overlays, inputs, and the infra dev shell
- `justfile` — operational entrypoint for checks, builds, deploys, and infra wrappers
- `hosts/` — host-specific NixOS configs
- `modules/` — reusable NixOS modules grouped by domain
- `home/` — Home Manager profiles and per-program config
- `scripts/` — personal shell helpers, wrapped into the system via `modules/packages/scripts.nix`
- `terraform/` — OpenTofu for `oddship-web` and `rhnvrm-private`
- `docs/` — smaller notes/reference set, now also usable as a moat site
- `secrets/` — agenix-managed secrets and recipients

## Common commands

`justfile` is meant to be the front door.

```bash
just help
just check
just build <host>
just switch <host>
just diff <host>
just fmt
just update
just secret list
just secret edit <name>
```

For `build`, `switch`, `debug`, and `diff`, the `host` argument defaults to the
current hostname.

## Provisioning and deploy flows

### `oddship-web`

For the public web box, use the wrapped workflow instead of driving `tofu`
manually unless you are debugging the stack.

```bash
nix develop
just server-init-key
just server-setup-secrets
just server-provision
just deploy oddship-web
```

Or run the full bootstrap in one shot:

```bash
nix develop
just server-setup
```

Useful follow-ups:

```bash
just tofu-ip
just deploy oddship-web
```

### `rhnvrm-private`

`rhnvrm-private` has its own OpenTofu stack under `terraform/rhnvrm-private/`
and its own `just` wrappers.

```bash
nix develop
just rhnvrm-init
just rhnvrm-init-key
just rhnvrm-provision
just rhnvrm-deploy
```

Useful follow-ups:

```bash
just rhnvrm-ip
just rhnvrm-deploy
```

## Docs

The repo now has two doc layers:

1. repo-local READMEs that explain how the tree is organized
2. `docs/`, which is the smaller public-facing subset built with moat

Local moat preview:

```bash
go install github.com/oddship/moat@latest
moat build docs/ _site/
moat serve _site/
```

The GitHub Pages workflow for that site lives in `.github/workflows/docs.yml`.
Once deployed, the site will be at `https://oddship.github.io/nix-system/`.

## Where to read next

- [`home/README.md`](home/README.md)
- [`modules/README.md`](modules/README.md)
- [`scripts/README.md`](scripts/README.md)
- [`skills/README.md`](skills/README.md)
- [`terraform/README.md`](terraform/README.md)
- [`hosts/servers/oddship-web/README.md`](hosts/servers/oddship-web/README.md)
- [`docs/`](docs/)
