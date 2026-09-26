{ pkgs, username, ... }:

{
  services = {
    xserver = {
      enable = true;
      windowManager.i3.enable = true;
      displayManager.startx = {
        enable = true;
        generateScript = true;
      };
    };

    greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.xinit}/bin/startx";
        user = "greeter";
      };
    };

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    flatpak = {
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
  };
  security.rtkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
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

  environment.systemPackages = with pkgs; [
    brave
    zed-editor
    keepassxc
  ];
}
