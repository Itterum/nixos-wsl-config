{ inputs, ... }:
{
  flake.nixosModules.noctalia = { pkgs, username, ... }: {
    home-manager.users.${username}.imports = [
      inputs.noctalia.homeModules.default
      ({ ... }: {
        programs.noctalia = {
          enable = true;
          package = pkgs.noctalia;
        };
      })
    ];
  };

  perSystem = { pkgs, ... }: {
    packages.myNoctalia = pkgs.noctalia;
  };
}
