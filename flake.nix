{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      ...
    }:
    {
      nixosConfigurations = {

        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            ./common.nix
            ./wsl.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./home.nix;
            }
          ];
        };

        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./common.nix
            ./laptop.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./home.nix;
            }
          ];
        };
      };
    };
}
