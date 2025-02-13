{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = self.packages.${system}.create-pin-refs;
        create-pin-refs = pkgs.callPackage ./create-pin-refs.nix { };
        test = pkgs.writers.writeBashBin "test" ''
          echo "this is a test package"
        '';
        test-linux = pkgs.writers.writeBashBin "test-linux" ''
          echo "only pin this on linux"
        '';
      });
  };
}
