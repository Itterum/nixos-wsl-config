{
  imports = [ ../nixos/system/graphical.nix ];

  networking.hostName = "desktop";

  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
