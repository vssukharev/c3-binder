{ pkgs ? import <nixpkgs> {} }: with pkgs;
mkShell {
  buildInputs = [ c3c ];
  shellHook = ''zsh'';
}

