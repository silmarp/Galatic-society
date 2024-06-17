{
  description = "Galatic society flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, nixpkgs, flake-utils }@inp:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              python311
              python311Packages.pip
              python311Packages.virtualenv

              python311Packages.flask
              python311Packages.oracledb

              nodePackages.pyright
              vscode-langservers-extracted
            ];
          };
        };
      });
}
