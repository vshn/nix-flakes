{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
}:
pkgs.buildGoLatestModule rec {
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
