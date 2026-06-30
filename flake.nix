{
  description = "A flake for VSHN tooling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    # No `follows` for poetry2nix's nixpkgs: poetry2nix's overrides only work
    # with the nixpkgs revision it was developed against, so commodore is
    # built from poetry2nix's own locked nixpkgs.
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = {
    self,
    nixpkgs,
    poetry2nix,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = nixpkgs.legacyPackages;
  in {
    packages = forAllSystems (system: {
      kharon = pkgsFor.${system}.callPackage ./kharon.nix {};
      commodore = let
        pkgs = poetry2nix.inputs.nixpkgs.legacyPackages.${system};
      in
        pkgs.callPackage ./commodore.nix {
          poetry2nix = poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
        };
    });
  };
}
