{
  description = "xav cargo-check shell (nightly rust + clang/lld/nasm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, fenix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # `complete` tracks nightly
        toolchain = fenix.packages.${system}.complete.withComponents [
          "cargo"
          "clippy"
          "rust-src"
          "rustc"
          "rustfmt"
        ];
      in {
        devShells.default = pkgs.mkShell {
          name = "xav-cargo-check";
          buildInputs = [
            toolchain
            pkgs.clang
            pkgs.lld
            pkgs.nasm
            pkgs.pkg-config
            pkgs.git
          ];
          shellHook = ''
            echo "xav cargo-check shell: $(rustc --version)"
          '';
          RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
        };
      });
}
