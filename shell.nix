{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    nil
    nixfmt-rfc-style
    statix
  ];

  shellHook = ''
    echo "Nix dev shell ready!"
  '';
}
