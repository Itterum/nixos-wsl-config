{ pkgs, ... }:

let
  modifier = "Mod4";
  refreshI3status = "${pkgs.procps}/bin/killall -SIGUSR1 i3status";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
in
{
  home.packages = with pkgs; [
    alacritty
    dex
    dmenu
    i3blocks
    i3lock
    networkmanagerapplet
    procps
    pulseaudio
    xss-lock
  ];

  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        modifier = modifier;
        fonts = {
          names = [ "DejaVu Sans Mono" ];
          size = 8.0;
        };
        floating.modifier = modifier;
        gaps = {
          inner = 4;
          outer = 4;
        };
        terminal = "${pkgs.alacritty}/bin/alacritty";
        menu = "${pkgs.dmenu}/bin/dmenu_run";

        startup = [
          {
            command = "${pkgs.dex}/bin/dex --autostart --environment i3";
            notification = false;
          }
          {
            command = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- ${pkgs.i3lock}/bin/i3lock --nofork";
            notification = false;
          }
          {
            command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
            notification = false;
          }
        ];

        keybindings = {
          "${modifier}+Return" = "exec ${pkgs.alacritty}/bin/alacritty";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+d" = "exec --no-startup-id ${pkgs.dmenu}/bin/dmenu_run";

          "${modifier}+j" = "focus left";
          "${modifier}+k" = "focus down";
          "${modifier}+l" = "focus up";
          "${modifier}+semicolon" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          "${modifier}+Shift+j" = "move left";
          "${modifier}+Shift+k" = "move down";
          "${modifier}+Shift+l" = "move up";
          "${modifier}+Shift+colon" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          "${modifier}+h" = "split h";
          "${modifier}+v" = "split v";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
          "${modifier}+Shift+e" =
            "exec \"${pkgs.i3}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' '${pkgs.i3}/bin/i3-msg exit'\"";
          "${modifier}+r" = "mode resize";

          "XF86AudioRaiseVolume" =
            "exec --no-startup-id ${pactl} set-sink-volume @DEFAULT_SINK@ +10% && ${refreshI3status}";
          "XF86AudioLowerVolume" =
            "exec --no-startup-id ${pactl} set-sink-volume @DEFAULT_SINK@ -10% && ${refreshI3status}";
          "XF86AudioMute" =
            "exec --no-startup-id ${pactl} set-sink-mute @DEFAULT_SINK@ toggle && ${refreshI3status}";
          "XF86AudioMicMute" =
            "exec --no-startup-id ${pactl} set-source-mute @DEFAULT_SOURCE@ toggle && ${refreshI3status}";
        };

        modes.resize = {
          j = "resize shrink width 10 px or 10 ppt";
          k = "resize grow height 10 px or 10 ppt";
          l = "resize shrink height 10 px or 10 ppt";
          semicolon = "resize grow width 10 px or 10 ppt";
          Left = "resize shrink width 10 px or 10 ppt";
          Down = "resize grow height 10 px or 10 ppt";
          Up = "resize shrink height 10 px or 10 ppt";
          Right = "resize grow width 10 px or 10 ppt";
          Return = "mode default";
          Escape = "mode default";
          "${modifier}+r" = "mode default";
        };

        bars = [
          {
            position = "top";
            trayOutput = "primary";
            statusCommand = "${pkgs.i3status}/bin/i3status";
          }
        ];
      };
      extraConfig = "tiling_drag modifier titlebar";
    };
  };

  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      interval = 1;
    };
    modules = {
      memory.position = 1;
      load.position = 2;
      "tztime local" = {
        position = 3;
        settings.format = "%Y-%m-%d %H:%M:%S";
      };
    };
  };
}
