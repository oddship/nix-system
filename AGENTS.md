# AGENTS.md - Coding Agent Guidelines

## Build/Lint/Test Commands
- `just switch` - Build and apply configuration
- `just build` - Build without switching  
- `just check` - Validate configuration syntax
- `just fmt` - Format Nix files with nixfmt
- `just test` - Test configuration in VM
- `just diff` - Show configuration changes
- `nix flake check` - Check flake validity

## Code Style Guidelines
- **Formatting**: Use nixfmt for consistent formatting
- **Modules**: Follow NixOS conventions with `options` and `config` sections
- **Options**: Use `lib.mkEnableOption` for toggles, `lib.mkDefault` for defaults
- **Structure**: Gate functionality with `lib.mkIf cfg.enable`
- **Naming**: Use descriptive, lowercase names with hyphens
- **Imports**: Group related imports, use absolute paths
- **Comments**: Minimal comments, focus on clarity through code
- **Error Handling**: Use `lib.mkDefault` for safe overrides

## Branch Naming
- Use `feat-*`, `fix-*`, `refactor-*` prefixes (no slashes)
- Example: `feat-add-dark-mode` not `feat/add-dark-mode`

## Commit Guidelines  
- Include prompts used in quotes when committing
- Avoid "Co-Authored-By" lines
- Focus on what changed, not just descriptive summaries
