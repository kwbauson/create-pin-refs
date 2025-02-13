{ system ? builtins.currentSystem
, storePath ? builtins.storePath
}:
builtins.mapAttrs (_: value: value.${system} or value) (import ./pins.nix { inherit storePath; })
