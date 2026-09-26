{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      nix-flatpak,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      username = "itterum";
      mkHost =
        {
          extraModules,
          homeModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username; };
          modules = [
            ./nixos/system/common.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${username}.imports = [ ./home/home.nix ] ++ homeModules;
            }
          ]
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        wsl = mkHost {
          extraModules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl.nix
          ];
        };
        laptop = mkHost {
          extraModules = [
            nix-flatpak.nixosModules.nix-flatpak
            ./hosts/laptop.nix
          ];
          homeModules = [ ./home/graphical.nix ];
        };
        desktop = mkHost {
          extraModules = [
            nix-flatpak.nixosModules.nix-flatpak
            ./hosts/desktop.nix
          ];
          homeModules = [ ./home/graphical.nix ];
        };
      };
    };
}
