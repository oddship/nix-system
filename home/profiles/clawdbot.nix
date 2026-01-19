{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nix-clawdbot.homeManagerModules.clawdbot
    ../programs/shell.nix
  ];

  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  programs.clawdbot = {
    enable = true;

    # Disable first-party plugins (peekaboo is macOS-only)
    firstParty = {
      peekaboo.enable = false;
      summarize.enable = false;
      oracle.enable = false;
    };

    # Main instance
    instances.default = {
      enable = true;

      # Systemd service for Linux
      systemd = {
        enable = true;
        unitName = "clawdbot-gateway";
      };

      # Anthropic API
      providers.anthropic = { };
    };

    # Disable plugins
    plugins = [ ];

    # Upstream clawdbot config for Discord channel
    config = {
      channels.discord = {
        enabled = true;
        tokenFile = "/run/agenix/discord-bot-token";
        dm = {
          enabled = true;
          policy = "pairing";
        };
        groupPolicy = "allowlist";
      };
    };
  };

  home.stateVersion = "24.11";
}
