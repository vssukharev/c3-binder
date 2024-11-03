{ pkgs ? import <nixpkgs> {} }: with pkgs;
mkShell {
  buildInputs = [ 
    c3c
    libclang.lib
  ];

  shellHook = ''zsh'';

  LIBRARY_PATH = builtins.concatStringsSep ":" [ "${libclang.lib}/lib" ];
}

