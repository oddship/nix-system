{
  description = "The oddship nix-system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Allow unfree packages for all of nixpkgs

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    flake-utils.url = "github:numtide/flake-utils";

# Using 0xc000022070's zen-browser flake which handles hash mismatches better
    # by re-uploading artifacts instead of relying on upstream replaceable artifacts
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    oddship-site = {
      url = "github:oddship/oddship.github.io";
    };

    rohanverma-site = {
      url = "github:rhnvrm/rohanverma.net";
    };

    s3site = {
      url = "github:rhnvrm/s3site/feat-hosted-service-v1";
      inputs.flake-utils.follows = "flake-utils";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      agenix,
      nix-flatpak,
      catppuccin,
      chaotic,
      flake-utils,
      ...
    }@inputs:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Development shell with OpenTofu and infrastructure tools
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs =
              with pkgs;
              [
                opentofu
                just
                jq
                curl
              ]
              ++ [
                agenix.packages.${system}.default
              ];

            shellHook = ''
              echo "Infrastructure dev shell loaded"
              echo "Available commands: tofu, just, jq, agenix"
            '';
          };
        }
      );

      nixosConfigurations."oddship-thinkpad-x1" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              (final: prev: {
                gnomeExtensions = prev.gnomeExtensions // {
                  tailscale-qs = prev.stdenvNoCC.mkDerivation {
                    pname = "gnome-shell-extension-tailscale-qs";
                    version = "5-unstable-2026-04-06";

                    src = prev.fetchFromGitHub {
                      owner = "tailscale-qs";
                      repo = "tailscale-gnome-qs";
                      rev = "3120bcb98d7ee44b013a06d7553358821c825762";
                      hash = "sha256-12V8SuwUf/qnGEkmDQ2Lf1EMWB5/EKn0namqsw3YY/E=";
                    };

                    dontBuild = true;

                    installPhase = ''
                      runHook preInstall
                      mkdir -p $out/share/gnome-shell/extensions
                      cp -r tailscale-gnome-qs@tailscale-qs.github.io                         $out/share/gnome-shell/extensions/
                      runHook postInstall
                    '';

                    passthru.extensionUuid = "tailscale-gnome-qs@tailscale-qs.github.io";

                    meta = with prev.lib; {
                      description = "GNOME Quick Settings extension for Tailscale";
                      homepage = "https://github.com/tailscale-qs/tailscale-gnome-qs";
                      license = licenses.gpl3Plus;
                      platforms = platforms.linux;
                    };
                  };
                };
              })
            ];
            chaotic.nyx.overlay.flakeNixpkgs.config = {
              allowUnfree = true;
            };
          }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          catppuccin.nixosModules.catppuccin
          chaotic.nixosModules.default

          ./hosts/desktop/thinkpadx1/configuration.nix
        ];
      };

      nixosConfigurations."oddship-ux303" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
          }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak

          ./hosts/ux303/configuration.nix
          ./hosts/ux303/hardware-config.nix
        ];
      };

      nixosConfigurations."oddship-beagle" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
          }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak

          ./hosts/servers/beagle/disko-config.nix
          ./hosts/servers/beagle/configuration.nix
        ];
      };

      nixosConfigurations."oddship-web" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
          }

          disko.nixosModules.disko
          agenix.nixosModules.default

          # Caddy with Cloudflare DNS plugin (2025 best practice)
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  caddy-with-cloudflare = prev.caddy.withPlugins {
                    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3-0.20251204174556-6dc1fbb7e925" ];
                    hash = "sha256-IA1h2PBQIy0zisXvLHf8XcmsohvpvKLBMopgTXN0GzI=";
                  };
                })
              ];

              services.caddy.package = pkgs.caddy-with-cloudflare;
            }
          )

          ./hosts/servers/oddship-web/configuration.nix
        ];
      };

      nixosConfigurations."rhnvrm-private" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              (final: prev: {
                caddy-with-tailscale = prev.caddy.withPlugins {
                  plugins = [ "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556" ];
                  hash = "sha256-oOW8PmJnqZkiDoU1eDFuMH2DNzd1O0oguQJgP3IdnDs=";
                };
              })
            ];
          }

          disko.nixosModules.disko
          agenix.nixosModules.default

          ./hosts/servers/rhnvrm-private/configuration.nix
        ];
      };
    };
}
