{ 
  mkShell,
  libclang,
  c3c,
}:
mkShell {
  buildInputs = [ 
    c3c
    libclang.lib
  ];

  shellHook = ''zsh'';

  LIBRARY_PATH = builtins.concatStringsSep ":" [ "${libclang.lib}/lib" ];
}

