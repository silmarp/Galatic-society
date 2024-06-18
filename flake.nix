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
<<<<<<< Updated upstream
              python311Packages.oracledb
=======
              python311Packages.flask-wtf
              python311Packages.oracledb
              python311Packages.python-dotenv
>>>>>>> Stashed changes

              nodePackages.pyright
              vscode-langservers-extracted
            ];
          };
        };
      });
}
