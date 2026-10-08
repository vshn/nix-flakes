{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
}:
pkgs.buildGoLatestModule rec {
  pname = "kharon";
  version = "2.0.0";
  owner = "vshn";

  src = fetchFromGitHub {
    owner = owner;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-oKUfNPbVSUAXGVtbc5ZtCE6k7ZfDxUof3MxrSX1ZIqY=";
  };

  proxyVendor = true;
  vendorHash = "sha256-0wiGyW+9fu+Sd/ymsIvHmkF5C87y5XbdpI3a4vjaofs=";

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
