{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
}:
pkgs.buildGoLatestModule rec {
  pname = "kharon";
  version = "1.8.1";
  owner = "vshn";

  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-24pIh1ZbqUOOEowTzdbuZdgw38oxEPwykqchYNIBFYI=";
  };

  proxyVendor = true;
  vendorHash = "sha256-Xh8Pd0vkNuJRS630BhYMrn9i6w+i1Iq2i1wyuSEeXl8=";

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
