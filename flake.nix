{
  description = "WebFisher";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = { ... } @ inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];

    perSystem = { self', system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nim
            nim_lk jq
          ];
          packagesFrom = [
            self'.packages.default.nativeBuildInputs
            self'.packages.default.buildInputs
          ];
          shellHook = ''
            nim_lk | jq --sort-keys > lock.json
          '';
        };
      };
      packages = {
        default = self'.packages.webfisher;
        webfisher = pkgs.callPackage ./default.nix { };
      };
    };
  };
}

