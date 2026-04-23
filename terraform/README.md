# terraform

OpenTofu lives here, but the normal entrypoint is still the root `justfile`.
Most day-to-day work should go through the wrapped `just` recipes so the token
handling, secret setup, and host-specific paths stay consistent.

## Stacks

| Path | Host | Purpose |
| --- | --- | --- |
| `terraform/` | `oddship-web` | Public Hetzner VM, Cloudflare DNS, nixos-anywhere install, pre-generated SSH host key for agenix. |
| `terraform/rhnvrm-private/` | `rhnvrm-private` | Private Hetzner VM, nixos-anywhere install, pre-generated SSH host key for agenix. |

## Shared pattern

Both stacks generate the host's SSH key before the machine exists. That lets the
repo encrypt agenix secrets for the host ahead of first boot instead of doing a
second provisioning pass later.

Both stacks also use the nixos-anywhere Terraform module rather than hand-rolled
remote install scripts.

## `oddship-web`

The main stack at `terraform/` currently provisions:

- a Hetzner server named `oddship-web`
- a firewall allowing `22`, `80`, and `443`
- Cloudflare records needed for the public web services
- an `extra-files.sh` script that injects the pre-generated host key
- nixos-anywhere install for `nixosConfigurations.oddship-web`

Root `justfile` wrappers for this stack:

```bash
nix develop
just tofu-init
just tofu-plan
just tofu-apply
just tofu-ip
```

For the end-to-end server workflow, use the higher-level wrappers instead:

```bash
nix develop
just server-init-key
just server-setup-secrets
just server-provision
just deploy oddship-web
```

Or:

```bash
nix develop
just server-setup
```

## `rhnvrm-private`

The private stack at `terraform/rhnvrm-private/` currently provisions:

- a Hetzner server named `rhnvrm-private`
- a firewall that only opens SSH publicly
- an `extra-files.sh` script that injects the pre-generated host key
- nixos-anywhere install for `nixosConfigurations.rhnvrm-private`

Root `justfile` wrappers for this stack:

```bash
nix develop
just rhnvrm-init
just rhnvrm-init-key
just rhnvrm-provision
just rhnvrm-ip
just rhnvrm-deploy
```

## When to use raw `tofu`

Drop into the stack directories directly when you need to inspect state or debug
provider behavior:

```bash
cd terraform
tofu plan

cd terraform/rhnvrm-private
tofu output
```

That should be the exception, not the default path.
