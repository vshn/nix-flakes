# VSHN Flake

This is a nix flake specifically for VSHN tooling.

Right now these tools are included:

- kharon
- commodore

## How to use

```nix
{
inputs = {
  vshnpkgs.url = "github:vshn/nix-flakes";
  vshnpkgs.inputs.nixpkgs.follows = "nixpkgs";  # share nixpkgs, smaller closure
};

outputs = { self, nixpkgs, vshnpkgs, ... }: {
  # ... your outputs
};
}
```

Then install via:

```nix
# NixOS config
environment.systemPackages = [ vshnpkgs.packages.${pkgs.system}.kharon ];

# home-manager
home.packages = [ inputs.vshnpkgs.packages.${pkgs.system}.kharon ];
```
