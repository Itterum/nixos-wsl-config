{ pkgs, username, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.defaultSession = "none+i3";

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  networking.networkmanager.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    group = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
  users.groups.${username} = { };

  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      {
        appId = "io.github.kolunmi.Bazaar";
        origin = "flathub";
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    brave
    zed-editor
    keepassxc
  ];
}
