{
  pkgs ? import <nixpkgs> {},
  fetchFromGitHub,
  poetry2nix,
  git ? pkgs.git,
}: let
  version = "1.34.1";

  src = fetchFromGitHub {
    owner = "projectsyn";
    repo = "commodore";
    rev = "v${version}";
    hash = "sha256-Q5E6Og27IGvTk6Fu4ZmXQY5yIE+ShKg6R5V2BI1a7p8=";
  };

  # Upstream's pyproject.toml is written for poetry >= 2 (PEP-621 [project]
  # table, poetry-dynamic-versioning placeholder version, legacy
  # poetry.masonry.api backend), none of which poetry2nix/poetry-core 1.9
  # understand. Rewrite it to classic [tool.poetry] metadata. Applied both to
  # the eval-time copy (projectDir) and the build tree (postPatch).
  patchPyproject = ''
    substituteInPlace pyproject.toml \
      --replace-fail '[tool.poetry]' '[tool.poetry]
    name = "syn-commodore"
    version = "${version}"
    description = "Commodore provides opinionated tenant-aware management of Kapitan inventories and templates"
    authors = ["VSHN AG <info@vshn.ch>"]' \
      --replace-fail 'version = "v0.0.0"' 'version = "${version}"' \
      --replace-fail 'requires = ["poetry>=0.12"]' 'requires = ["poetry-core"]' \
      --replace-fail 'build-backend = "poetry.masonry.api"' 'build-backend = "poetry.core.masonry.api"'

    # poetry-core 1.9 also ignores the PEP-621 [project.scripts] table, so
    # mirror the commodore entry point into [tool.poetry.scripts]. Upstream
    # also declares a kapitan entry point, but the kapitan dependency already
    # ships that script and the two would collide in dependencyEnv.
    cat >> pyproject.toml <<'EOF'

    [tool.poetry.scripts]
    commodore = "commodore.cli:main"
    EOF
  '';
  app = poetry2nix.mkPoetryApplication {
    pname = "commodore";
    inherit version src;

    # poetry2nix parses pyproject.toml and poetry.lock from projectDir at eval
    # time, so those fixes must be baked into the tree before it looks at it.
    # src stays the plain GitHub fetch so nix-update can bump it.
    projectDir = pkgs.applyPatches {
      inherit src;
      postPatch =
        patchPyproject
        + ''
          # poetry2nix's PEP 508 marker parser does not understand the ~=
          # operator; ~= "3.10" is equivalent to >= 3.10, < 4 and all our
          # pythons satisfy it.
          substituteInPlace poetry.lock \
            --replace-fail 'python_version ~= \"3.10\"' 'python_version >= \"3.10\"'

          # poetry2nix cannot parse GraalPy ABI tags (graalpy242_311_native);
          # we only build for CPython, so drop those wheel entries.
          sed -i '/graalpy/d' poetry.lock
        '';
    };

    postPatch = patchPyproject;

    # Pull prebuilt wheels for the native dependencies (gojsonnet, reclass-rs,
    # ...) instead of building them from source.
    preferWheels = true;
  };
in
  # Expose the app through its dependencyEnv: a single merged site-packages.
  # commodore runs cookiecutter/cruft hooks in `sys.executable` subprocesses,
  # which only inherit the interpreter, not the per-script sys.path injection
  # of the plain application output — with dependencyEnv the interpreter
  # itself sees all dependencies.
  pkgs.runCommand "commodore-${version}"
  {
    nativeBuildInputs = [pkgs.makeWrapper];

    passthru = {
      inherit version src;
      updateScript = pkgs.nix-update-script {};
    };

    meta = with pkgs.lib; {
      description = "Tenant-aware management of Kapitan inventories and templates";
      homepage = "https://github.com/projectsyn/commodore";
      license = licenses.bsd3;
      mainProgram = "commodore";
    };
  }
  ''
    mkdir -p $out/bin
    # GitPython shells out to the git binary; helm, jb and kustomize are
    # managed by commodore's own tool handling (commodore tool install).
    makeWrapper ${app.dependencyEnv}/bin/commodore $out/bin/commodore \
      --suffix PATH : ${pkgs.lib.makeBinPath [git]}
    ln -s ${app.dependencyEnv}/bin/kapitan $out/bin/kapitan
  ''
