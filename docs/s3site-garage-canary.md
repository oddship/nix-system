# s3site + Garage hosted sites on `oddship-web`

This note captures the hosted static-site design for serving both `rohanverma.net` and `oddship.net` from `oddship-web` without rebuilding the VPS for each content publish.

## Topology

- `rhnvrm-private`
  - runs Garage S3
  - exposes the S3 API to Tailscale peers only
- `oddship-web`
  - runs Caddy publicly
  - runs `s3site` on localhost
  - joins Tailscale and reads site archives from Garage
- GitHub Actions (`rhnvrm/rohanverma.net`, `oddship/oddship.net`)
  - join Tailscale with `tailscale/github-action`
  - build site tarballs and upload them to Garage
  - let `oddship-web` pick up uploads on the next `s3site` poll

## Current object-store contract

- Garage endpoint: `http://rhnvrm-private:3900`
- bucket: `static-sites`
- region: `garage`
- site keys:
  - `sites/rohanverma.net.tar.gz`
  - `sites/oddship.net.tar.gz`

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
- site artifact uploads

## Secret model

Use separate credentials for runtime and CI.

### `oddship-web` runtime key
Purpose: `s3site` reads hosted site tarballs from Garage.

Required grants on `static-sites`:
- read only

Stored in agenix secret:
- `secrets/oddship-web-s3site-env.age`

Payload shape:

```bash
AWS_S3_ACCESS_KEY=...
AWS_S3_SECRET_KEY=...
```

### `oddship-web` Tailscale auth
Stored in agenix secret:
- `secrets/oddship-web-tailscale-auth.age`

Payload shape:

```text
<raw OAuth client secret>
```

Use a dedicated OAuth client with the `auth_keys` scope restricted to `tag:oddship-web`.
The host uses the built-in `services.tailscale.authKeyFile` flow with:

- `authKeyParameters = { ephemeral = false; preauthorized = true; }`
- `extraUpFlags = [ "--advertise-tags=tag:oddship-web" ]`

### CI upload keys
Purpose: each publishing repo uploads its own tarball to Garage.

Required grants on `static-sites`:
- read
- write

Recommended layout:
- `rohanverma-site-ci` for `rhnvrm/rohanverma.net`
- `oddship-site-ci` for `oddship/oddship.net`

Mapped to repository secrets:
- `S3SITE_ACCESS_KEY_ID`
- `S3SITE_SECRET_ACCESS_KEY`

Do not reuse the `oddship-web` runtime read-only key for CI.

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

sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage key create oddship-site-ci'
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage bucket allow --read --write static-sites --key oddship-site-ci'

sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage key create oddship-web-runtime'
sudo bash -lc 'set -a; source /run/agenix/rhnvrm-private-env; set +a; garage bucket allow --read static-sites --key oddship-web-runtime'
```

## oddship-web config contract

`oddship-web` hosts both public sites through one local `s3site` listener.

- `services.s3site.listen = "127.0.0.1:9001"`
- `services.s3site.poll = "5m"`
- hosted sites:
  - `oddship.net`
  - `rohanverma.net`

Caddy reverse proxies both domains to that local listener.

## Publishing flow

### `rhnvrm/rohanverma.net`
- workflow uploads `sites/rohanverma.net.tar.gz`

### `oddship/oddship.net`
- workflow uploads `sites/oddship.net.tar.gz`

Both workflows:
- build locally in GitHub Actions
- join the tailnet
- upload via `aws s3api put-object`
- verify object existence with `head-object`
- rely on `s3site` polling instead of SSH refresh

## Enable sequence

1. Bootstrap the Garage bucket and CI/runtime keys on `rhnvrm-private`
2. Create or update the agenix secrets for `oddship-web`
3. Add repo secrets to `rhnvrm/rohanverma.net`
4. Add repo secrets to `oddship/oddship.net`
5. Deploy `oddship-web`
6. Upload initial tarballs for both sites
7. Verify both domains return `200`

## Rollback

If hosted serving misbehaves:

1. restore the old static-site wiring in `hosts/servers/oddship-web/configuration.nix`
2. deploy `oddship-web`
3. both domains fall back to the old Nix-built static roots
