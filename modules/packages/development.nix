{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.packages.development;
in
{
  options.packages.development = {
    enable = lib.mkEnableOption "development tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Version control
      git
      git-lfs
      gh

      # Terminal tools
      tmux
      just
      
      # Languages and runtimes
      go
      python3
      lua
      zig
      rustc
      cargo
      gcc
      gnumake
      cmake
      nodejs
      bun
      deno

      # Python tools
      uv
      poetry
      pipenv

      # Build tools
      meson
      ninja
      pkg-config
      
      # Development utilities
      gdb
      valgrind
      strace
      ltrace
      lsof
      
      # Container tools
      dive
      lazydocker
      docker-compose

      # Cloud tools
      awscli2
      google-cloud-sdk
      azure-cli
      terraform
      
      # Database clients
      postgresql
      mysql
      redis
      sqlite

      # API tools
      httpie
      curl
      wget
      postman
      insomnia

      # Nix tooling
      inputs.agenix.packages.${pkgs.system}.default
      nix-prefetch-git
      nix-tree
      nix-diff
      cachix

      # Network tools
      nftables
      iptables
      tcpdump
      nmap
      netcat

      # Kubernetes tools
      kubectl
      k9s
      helm
      minikube

      # Misc development tools
      nomad
      consul
      vault
      jq
      yq
      fx
      glow
      pandoc
    ];
  };
}