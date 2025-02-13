{ writers
, lib
, jq
, curl
, coreutils
, gnutar
, gzip
}:
writers.writeBashBin "create-pin-refs" ''
  export PATH=${lib.makeBinPath [ jq curl coreutils gnutar gzip ]}
  set -euo pipefail
  if [[ -z ''${1-} || -n ''${2-} ]];then
    echo "generate store references from cachix pins"
    echo "usage: cachix-pins-eval-cache <cache>"
    exit 1
  fi
  cache=$1

  mkdir -p pins
  cd pins
  echo "\"https://$cache.cachix.org\"" > store.nix
  (
    echo "{ storePath }:"
    echo "{"
    curl --silent "https://app.cachix.org/api/v1/cache/$cache/pin" |
      jq -r '.[] | "  \"\(.name | gsub("\\."; "\".\""))\" = storePath \(.lastRevision.storePath);"'
    echo "}"
  ) > pins.nix
  cp --no-preserve=mode ${./copied-flake.nix} flake.nix
  cp --no-preserve=mode ${./copied-default.nix} default.nix
  cd ..
  tar czf pins.tar.gz pins
  mv pins.tar.gz pins
''
