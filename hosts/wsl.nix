{ username, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.interop.register = true;
  wsl.ssh-agent = {
    enable = true;
    users = [ username ];
  };

  networking.hostName = "wsl";
}
