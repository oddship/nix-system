{
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
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    nixosConfigurations."thinkpad-x1" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        {
          disko.devices = {
            disk = {
              main = {
                device = "/dev/nvme0n1";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      type = "EF00";
                      size = "512M";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        mountOptions = [ "umask=0077" ];
                      };
                    };
                    luks = {
                      size = "100%";
                      content = {
                        type = "luks";
                        name = "cryptroot";
                        settings.allowDiscards = true;
                        content = {
                          type = "btrfs";
                          subvolumes = {
                            "/root" = {
                              mountpoint = "/";
                              mountOptions = [ "compress=zstd" ];
                            };
                            "/home" = {
                              mountpoint = "/home";
                              mountOptions = [ "compress=zstd" ];
                            };
                            "/nix" = {
                              mountpoint = "/nix";
                              mountOptions = [ "compress=zstd" ];
                            };
                            "/var/log" = {
                              mountpoint = "/var/log";
                              mountOptions = [ "compress=zstd" ];
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        }
      ];
    };
  };
}

