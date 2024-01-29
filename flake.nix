{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, flake-utils, nixpkgs, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = (import nixpkgs) {
          inherit system overlays;
        };
        
        toolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
          extensions = [ "rust-src" "rust-analyzer" ];
        });
      in {
        devShell = pkgs.mkShell rec {
          nativeBuildInputs = [
            toolchain
            pkgs.pkg-config pkgs.clang
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs can be set here
            pkgs.libiconv pkgs.rustPlatform.bindgenHook
            pkgs.darwin.apple_sdk.frameworks.Cocoa
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeBuildInputs;
        };
      }
    );
}
