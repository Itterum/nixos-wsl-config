{
  ...
}:

{
  environment.sessionVariables = {
    TERM = "xterm-256color";
    COLORTERM = "truecolor";
  };

  programs.bash.enable = true;
  programs.direnv.enable = true;
  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
