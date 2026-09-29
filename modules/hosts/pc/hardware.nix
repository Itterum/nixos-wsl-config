{ ... }:
{
  flake.nixosModules.pcHardware = { lib, ... }: {
    # Replace this stub with the hardware settings generated on the actual PC.
    # In particular, define fileSystems."/" and configure its boot loader.
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
