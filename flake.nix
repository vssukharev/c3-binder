{
  description = "Flake for c3-binder";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    c3c.url = "github:c3lang/c3c";
  };

  outputs = { self, ... } @ inputs: inputs.flake-utils.lib.eachDefaultSystem (system: 
    let 
      pkgs = import inputs.nixpkgs { inherit system; }; 
      cp = pkgs.callPackage;
      c3c = inputs.c3c.packages.${system}.c3c;
    in 
    {
      devShells.default = cp ./shell.nix { inherit c3c; };
    }
  );
}
