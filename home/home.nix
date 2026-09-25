{ ... }:

{
  imports = [
    ./programs/helix
  ];

  programs.home-manager.enable = true;

  programs.gh.enable = true;
  programs.bat.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "lyashenko.ivan";
      user.email = "ivan.lyashenko.it@gmail.com";
      init.defaultBranch = "main";
    };
  };

  home.stateVersion = "26.05";
}
