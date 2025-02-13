{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
    in
    {
      packages = lib.genAttrs lib.systems.flakeExposed (system: {
        default = nixpkgs.legacyPackages.${system}.callPackage ./create-pin-refs.nix { };
      });
    };
}
