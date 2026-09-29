{ self, inputs, ... }:
{
  flake.nixosModules.wslConfiguration = { username, ... }: {
    imports = [
      self.nixosModules.common
      self.nixosModules.home-manager
      inputs.nixos-wsl.nixosModules.default
    ];

    environment.sessionVariables.GH_BROWSER = "explorer.exe";

    wsl = {
      enable = true;
      defaultUser = username;
      interop.register = true;
      ssh-agent = {
        enable = true;
        users = [ username ];
      };
    };

    networking.hostName = "wsl";
  };
}
