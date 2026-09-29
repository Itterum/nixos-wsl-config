{ pkgs, ... }:

{
  home.packages = with pkgs; [
    alacritty
    brave
    zed-editor
    keepassxc
  ];
}
