{ username, ... }:

{
  environment.sessionVariables.GH_BROWSER = "explorer.exe";

  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.interop.register = true;
  wsl.ssh-agent = {
    enable = true;
    users = [ username ];
  };

  networking.hostName = "wsl";
}
