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

    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # Using 0xc000022070's zen-browser flake which handles hash mismatches better
    # by re-uploading artifacts instead of relying on upstream replaceable artifacts
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
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
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations."oddship-thinkpad-x1" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
          catppuccin.nixosModules.catppuccin

          ./hosts/desktop/thinkpadx1/configuration.nix
        ];
      };

      nixosConfigurations."oddship-ux303" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak

          ./hosts/ux303/configuration.nix
          ./hosts/ux303/hardware-config.nix
        ];
      };

      nixosConfigurations."oddship-beagle" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.config.allowUnfree = true; }

          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak

          ./hosts/servers/beagle/disko-config.nix
          ./hosts/servers/beagle/configuration.nix
        ];
      };
    };
}
