{ ... }:
{
  flake.nixosModules.graphical = { inputs, username, ... }: {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
      ../../nixos/system/graphical.nix
    ];

    home-manager.users.${username}.imports = [ ../../home/graphical.nix ];
  };
}
