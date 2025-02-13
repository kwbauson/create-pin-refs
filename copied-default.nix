{ system ? builtins.currentSystem
, storePath ? builtins.storePath
}:
let
  mkDrv = path: {
    type = "derivation";
    outPath = path;
  };
  pins = (import ./pins.nix { inherit storePath; });
in
builtins.mapAttrs (_: value: mkDrv (value.${system} or value)) pins
