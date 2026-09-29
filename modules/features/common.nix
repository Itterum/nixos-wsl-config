{ ... }:
{
  flake.nixosModules.common = { ... }: {
    imports = [ ../../nixos/system/common.nix ];
  };

  flake.nixosModules.home-manager = { inputs, username, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.${username}.imports = [ ../../home/home.nix ];
    };
  };
}
