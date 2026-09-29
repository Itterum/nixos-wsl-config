{ self, inputs, ... }:
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      username = "itterum";
    };
    modules = [ self.nixosModules.nixosConfiguration ];
  };
}
