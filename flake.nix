{
  description = "The oddship nix-system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      home-manager,
      agenix,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations."oddship-thinkpad-x1" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          ./disko-config.nix
          agenix.nixosModules.default
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
