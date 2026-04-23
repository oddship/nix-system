# oddship-web

`oddship-web` is the public-facing box in this repo. It is the machine that
terminates web traffic for the public sites and hosts the small services that
actually need public reachability.

## What runs here

At the moment the host is responsible for:

- Caddy with the Cloudflare DNS plugin for certificate issuance
- `s3site`, which serves `oddship.net` and `rohanverma.net` from Garage-backed
  tarball uploads
- two Linkpage instances for `links.rohanverma.net` and `links.oddship.net`
- Umami at `analytics.rohanverma.net`
- Tailscale, so the host can reach Garage on `rhnvrm-private` without exposing
  that object store publicly

## Files worth opening

| File | Why it matters |
| --- | --- |
| `configuration.nix` | Main host config: users, reverse proxies, secrets, Linkpage, Umami, Tailscale, and `s3site`. |
| `disko-config.nix` | Disk layout for the host. |
| `../../../modules/services/server.nix` | Shared public Caddy wrapper used by this host. |
| `../../../modules/services/s3site.nix` | Service module for the hosted-site path. |
| `../../../docs/s3site-garage-canary.md` | Notes on the `s3site` + Garage deployment model. |
| `../../../terraform/` | Infra bootstrap for the server and its DNS records. |

## Deploy and bootstrap

For normal config changes:

```bash
just deploy oddship-web
```

For a fresh server build:

```bash
nix develop
just server-setup
```

Or, if you need the steps separately:

```bash
nix develop
just server-init-key
just server-setup-secrets
just server-provision
```

Useful checks:

```bash
just tofu-ip
ssh rhnvrm@$(just tofu-ip)
```

## Secrets this host needs

- `cloudflare-api-token.age`
- `umami-app-secret.age`
- `oddship-web-linkpage-rohan-password.age`
- `oddship-web-linkpage-oddship-password.age`
- `oddship-web-s3site-env.age`
- `oddship-web-tailscale-auth.age`

Terraform injects the SSH host key during install so agenix can decrypt these on
first boot.

## Mental model

`oddship-web` is best thought of as a thin public edge:

- public HTTP entrypoint lives here
- mutable static site content lives in Garage on `rhnvrm-private`
- CI uploads site tarballs
- `s3site` polls and serves the extracted content

That split keeps the host config declarative without forcing a full machine
rebuild for every site publish.
