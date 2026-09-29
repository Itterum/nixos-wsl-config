{ self, ... }:
{
  flake.nixosModules.nixosConfiguration = { pkgs, username, ... }: {
    imports = [
      self.nixosModules.common
      self.nixosModules.home-manager
      self.nixosModules.graphical
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.nixosHardware
    ];

    networking.hostName = "nixos";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    time.timeZone = "Europe/Chisinau";
    i18n.defaultLocale = "en_US.UTF-8";

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
  };
}
