# Agent guide

## Discover before changing

- Use `flake.nix` to discover hosts, inputs, overlays, and development tooling.
  Follow the relevant host's imports to find the configuration that owns a setting.
- Discover commands with `just --list`; read their implementations in `justfile`
  and any scripts they invoke to understand arguments, validation, and side effects.
- Use `rg --files` and `rg` to locate related configuration and existing patterns.
  Consult nearby READMEs for context; resolve discrepancies against the code.
- Keep this guide focused on durable conventions. Leave host inventories, command
  catalogs, keybindings, and implementation details in their authoritative files.

## Changes and verification

- Follow the surrounding NixOS and Home Manager conventions. Keep changes scoped
  to the request and put settings where they are owned; introduce abstractions
  only when they improve reuse or readability.
- Prefer existing package sources and tooling. Avoid unrelated dependency updates
  and compatibility-setting changes.
- Trace references when adding or removing functionality, including imports,
  enable flags, preferences, and supporting configuration.
- Discover and run formatting and checks appropriate to the changed files.
  Distinguish evaluation, building, and activation; report what actually ran.
  Documentation-only changes do not need a system rebuild.
- Inspect deployment and provisioning implementations before running them.
  Keep decrypted secrets out of source, logs, and commits.

## Git

- Before committing, inspect the working tree, recent commit messages, and history
  for the affected files to learn the repository's patterns and scopes.
- Use Conventional Commits: `type(scope): description`, or `type: description`
  when no scope is useful.
- Review both working-tree and staged diffs. Stage only intended changes,
  verify additions and deletions, and run `git diff --check` before committing.
- Preserve unrelated work. Do not rewrite published history unless requested.
