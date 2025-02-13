# Pull nix builds from cachix without needing to evaluate heavy nix expressions

This package allows you to use a combination of [cachix pins](https://docs.cachix.org/pins) and [github pages](https://pages.github.com/) to provide a pseudo-evaluation cache for your `nix` CI builds.

## Usage

Assuming you have a working cachix setup and have enabled Github Actions to publish to github pages, this repo can serve as a template.

The [build](.github/workflows/build.yml) workflow builds packages for both linux and macos, pushes them to cachix, and pins those builds.

The [publish-pins](.github/workflows/publish-pins.yml) workflow makes those pins available to use through the `nix` cli via github pages.

As long as you have your machine configured to use your cachix and the `publish-pins` workflow has comleted, you can build/run pins that only pull from the cache and skip evaluation:

```bash
nix build -f nix-build https://kwbauson.github.io/create-pin-refs/pins test
# or
nix shell -f https://kwbauson.github.io/create-pin-refs/pins test -c test
```

NOTE: `nix` will cache the avaiable pins for an hour by default. This can be overridden with the `tarball-ttl` setting, or by passing `--refresh` to your commands e.g. `nix --refresh build ...`

You can also use flake syntax as long you pass the `--impure` flag:

```bash
nix run --impure https://kwbauson.github.io/create-pin-refs/pins#test
```

If you have the experimental-feature [fetch-closure](https://nix.dev/manual/nix/latest/language/builtins.html#builtins-fetchClosure) enabled, you do not need the `--impure` flag.
However, you'll need to adjust your cachix cache settings to not use https://cache.nixos.org as an upstream cache, since this results in closures being split across caches, which `fetchClosure` does not support.

```bash
nix run https://kwbauson.github.io/create-pin-refs/pins#test
```


## How it works

This script generates a `pins.nix` file based on avaiable cachix pins that simply maps pin names to store paths.
The pins are bundled into a tarball with a default.nix and flake.nix that reference the generated `pins.nix`.
None of these nix files have external dependencies, so evaluation of those expressions is trivial (not much more more complicated than reading a JSON file).
Then this tarball is served by github pages, which the `nix` cli can interact with via URL.
The nix expressions use `builtins.storePath` (or the experimental `builtins.fetchClosure`) to create a dependency on store paths without needing to evaluate anything.
Since the list of store paths are generated from cachix pins, they can be substituted from the cache with no evalation of nix code.

Github pages is only being used as free public file serving.
This could easily be replaced by an s3 bucket.
Simiarly, an s3 cache of store paths could be used instead of cachix.
All that's needed is the ability to serve tarballs and map names to cached store paths.

## TODO

- Don't require overwriting github pages for the repo.
- The current workflow publishes updates to github-pages via actions, which usually takes about a minute. Publishing via pushing to a branch could be faster as well as complete within build workflows.
- Investigate pulling derivation paths from cachix narinfo files. This may allow creating fake derivations that are more like what the `nix` cli expects, instead of only store paths/flake apps.
