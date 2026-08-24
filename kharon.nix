{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
}:
pkgs.buildGoLatestModule rec {
  pname = "kharon";
  version = "1.8.0";
  owner = "vshn";

  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Z2cEKdt8cYa6d6bpwASqyhMyMyR9V6Ap3c1SW1aFgUk=";
  };

  proxyVendor = true;
  vendorHash = "sha256-WQphhZuX7uIHjSFJpqzBv83Tgt8kq2AXnwCSgCgg6tY=";

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
