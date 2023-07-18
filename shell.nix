{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs
    pkgs.nodePackages.npm
  ];

  shellHook = ''
    npm install zenn-cli
    npx zenn init
    npx zenn
  '';
}

