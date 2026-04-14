# s3site + Garage canary for `rohanverma.net`

This note captures the first canary design for moving `rohanverma.net` off the old content-triggered `nixos-rebuild switch` flow.

## Topology

- `rhnvrm-private`
  - runs Garage S3
  - exposes the S3 API to Tailscale peers only
- `oddship-web`
  - runs Caddy publicly
  - runs `s3site` on localhost
  - joins Tailscale to fetch site archives from Garage
- GitHub Actions (`rhnvrm/rohanverma.net`)
  - joins Tailscale with `tailscale/github-action`
  - uploads site tarballs to Garage
  - SSHes to `oddship-web` with a dedicated deploy key
  - runs `sudo /run/current-system/sw/bin/s3site refresh`

## Current object-store contract

- Garage endpoint: `http://rhnvrm-private:3900`
- bucket: `static-sites`
- region: `garage`
- site key: `sites/rohanverma.net.tar.gz`

## Why this split

This keeps long-lived infra declarative in Nix:
- Caddy
- `s3site`
- Tailscale on `oddship-web`
- agenix-managed runtime secrets

And keeps mutable object-store control-plane state out of ordinary host activation:
- bucket creation
- Garage S3 access-key issuance
- GitHub Actions secrets

For the first canary, Garage bucket/key bootstrap is intentionally one-time manual work.
That is simpler and lower-risk than coupling bucket reconciliation to `nix switch`.

## Secret model

Use separate credentials for CI and runtime.

### CI upload key
Purpose: GitHub Actions uploads tarballs to Garage.

Required grants on `static-sites`:
- read
- write

Mapped to GitHub Actions secrets:
- `S3SITE_ACCESS_KEY_ID`
- `S3SITE_SECRET_ACCESS_KEY`

### oddship-web runtime key
Purpose: `s3site` reads site tarballs from Garage.

Required grants on `static-sites`:
- read only

Stored in agenix secret:
- `secrets/oddship-web-s3site-env.age`

Payload shape:

```bash
AWS_S3_ACCESS_KEY=...
AWS_S3_SECRET_KEY=...
```

### oddship-web Tailscale auth
Stored in agenix secret:
- `secrets/oddship-web-tailscale-auth.age`

Payload shape:

```bash
TAILSCALE_AUTH_KEY=...
```

### GitHub Actions deploy SSH key
Purpose: SSH from GitHub Actions into `oddship-web` as `rhnvrm`.

Mapped to GitHub Actions secret:
- `DEPLOY_SSH_KEY`

The workflow uses `sudo` for refresh because the unix control socket is not readable by an unprivileged user.

## Garage admin CLI note

On `rhnvrm-private`, the `garage` CLI needs the RPC secret from the agenix env file.
Run admin commands like this:

```bash
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage status'
```

Examples:

```bash
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage bucket info static-sites >/dev/null 2>&1 || garage bucket create static-sites'

sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage key create rohanverma-site-ci'
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage bucket allow --read --write static-sites --key rohanverma-site-ci'

sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage key create rohanverma-site-runtime'
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage bucket allow --read static-sites --key rohanverma-site-runtime'
```

## Agenix setup

The canary wiring expects these future secret files:

- `secrets/oddship-web-s3site-env.age`
- `secrets/oddship-web-tailscale-auth.age`

They are already listed in `secrets/secrets.nix` for recipients:
- `rhnvrm_ed25519`
- `oddship_web`

Create them with `agenix -e` before turning on the canary.

## Enable sequence

1. Publish `rhnvrm/s3site` with its `flake.nix`
2. Update `oddship/nix-system` to that `s3site` commit
3. Bootstrap Garage bucket and keys manually on `rhnvrm-private`
4. Create the two agenix secrets for `oddship-web`
5. Add GitHub Actions secrets in `rhnvrm/rohanverma.net`
6. Set `enableS3SiteCanary = true` in `hosts/servers/oddship-web/configuration.nix`
7. Deploy `oddship-web`
8. Run the manual canary workflow in `rohanverma.net`

## Rollback

If the canary misbehaves:

1. set `enableS3SiteCanary = false`
2. deploy `oddship-web`
3. `rohanverma.net` falls back to the old static-root path
