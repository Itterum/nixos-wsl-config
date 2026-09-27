{
  pkgs,
  ...
}:

{
  environment.sessionVariables = {
    TERM = "xterm-256color";
    COLORTERM = "truecolor";
  };

  environment.systemPackages = with pkgs; [
    curl
    wget
  ];

  programs = {
    bash.enable = true;
    direnv.enable = true;
    nix-ld.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
