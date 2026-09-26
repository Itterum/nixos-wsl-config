{ pkgs, username, ... }:

{
  imports = [
    ../nixos/system/graphical.nix
    ./laptop-hardware.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "laptop";

  time.timeZone = "Europe/Chisinau";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:shifts_toggle,ctrl:nocaps";
  };

  services.displayManager.autoLogin.enable = false;

  users.users.${username}.description = username;

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      inter
      roboto
    ];

    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [
        "Inter"
        "DejaVu Sans"
      ];
    };
  };
}
