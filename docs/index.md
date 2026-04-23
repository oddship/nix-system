---
title: nix-system
description: Overview for the nix-system repo and its published notes.
---

# nix-system

This site is the published subset of the repo docs: short operational notes
and references that are easier to browse on the web. The repo-local READMEs are
still the fuller map of the tree.

## Current hosts

| Host | Role | Notes |
| --- | --- | --- |
| `oddship-thinkpad-x1` | workstation | Main GNOME machine and the place where most of the user-environment work lands first. |
| `oddship-ux303` | laptop server | Repurposed laptop with Wi-Fi and server-ish defaults. |
| `oddship-beagle` | minimal server | Small baseline NixOS box. |
| `oddship-web` | public web host | Caddy, Linkpage, Umami, and `s3site`. |
| `rhnvrm-private` | private services host | Garage, Gitea, Vaultwarden, and Tailscale-only internal services. |

## Core entry points in the repo

- [`flake.nix`](https://github.com/oddship/nix-system/blob/master/flake.nix)
- [`justfile`](https://github.com/oddship/nix-system/blob/master/justfile)
- [`README.md`](https://github.com/oddship/nix-system/blob/master/README.md)
- [`home/README.md`](https://github.com/oddship/nix-system/blob/master/home/README.md)
- [`modules/README.md`](https://github.com/oddship/nix-system/blob/master/modules/README.md)
- [`scripts/README.md`](https://github.com/oddship/nix-system/blob/master/scripts/README.md)
- [`terraform/README.md`](https://github.com/oddship/nix-system/blob/master/terraform/README.md)

## Notes in this site

- [Claude + Zellij orchestration](claude-zellij-orchestration/)
- [Zellij reference](zellij-reference/)
- [s3site + Garage canary path](s3site-garage-canary/)

## Local preview

This site is built with [moat](https://github.com/oddship/moat):

```bash
go install github.com/oddship/moat@latest
moat build docs/ _site/
moat serve _site/
```
