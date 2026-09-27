{ username, ... }:

{
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
}
