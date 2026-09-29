{ self, inputs, ... }:
{
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        settings = {
          spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) ];
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb = {
            layout = "us,ru";
            options = "grp:shifts_toggle,ctrl:nocaps";
          };
          layout.gaps = 5;

          binds = {
            "Mod+Return".spawn = [ (lib.getExe pkgs.alacritty) ];
            "Mod+Q".close-window = { };
            "Mod+S".spawn = [
              (lib.getExe self'.packages.myNoctalia)
              "msg"
              "panel-toggle"
              "launcher"
            ];
            "Mod+Shift+E".quit = { };
          };
        };
      };
    };
}
