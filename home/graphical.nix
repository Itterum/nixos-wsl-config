{ pkgs, ... }:

{
  imports = [ ./programs/i3 ];

  home.packages = with pkgs; [
    brave
    zed-editor
    keepassxc
  ];
}
