{ pkgs, username, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.xinit}/bin/startx";
      user = "greeter";
    };
  };

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;

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
