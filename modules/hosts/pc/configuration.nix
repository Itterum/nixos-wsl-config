{ self, ... }:
{
  flake.nixosModules.pcConfiguration = { ... }: {
    imports = [
      self.nixosModules.common
      self.nixosModules.home-manager
      self.nixosModules.graphical
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.pcHardware
    ];

    networking.hostName = "pc";

    hardware.graphics.enable = true;
    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
