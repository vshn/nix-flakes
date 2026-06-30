{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
}: let
  # kharon's dependency tree (tailscale.com) requires go >= 1.26.4 but nixpkgs
  # still ships 1.26.3; build with an overridden toolchain until nixpkgs
  # catches up, then drop this and go back to plain buildGoLatestModule.
  go_1_26_4 = pkgs.go_latest.overrideAttrs (old: rec {
    version = "1.26.4";
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      hash = "sha256-T2aKMvv8ETLmqIH7lowvHa2mMUkqM5IRc1+7JVpCYC0=";
    };
  });
in
  pkgs.buildGoLatestModule.override {go = go_1_26_4;} rec {
    pname = "kharon";
    version = "1.7.4";
    owner = "vshn";

    src = fetchFromGitHub {
      owner = owner;
      repo = pname;
      rev = "v${version}";
      hash = "sha256-x+IiDOup7ZWYy+IQP31PXNuxKEmwLCbh9JQPWVgCMuY=";
    };

    proxyVendor = true;
    vendorHash = "sha256-w7JyDKCAKB7nni++GWIXtA4KES+V6VaLpHNPNY2ljcs=";

    subPackages = ["."];

    preBuild = ''
      go generate ./...
    '';

    passthru.updateScript = pkgs.nix-update-script {};

    meta = with pkgs.lib; {
      description = "Ferries your connections safely across SSH jumphosts into private networks";
      homepage = "https://github.com/vshn/kharon";
      license = licenses.bsd3;
      mainProgram = "kharon";
    };
  }
