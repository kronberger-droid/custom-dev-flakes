{
  description = "Rust development environment for multiple projects (impure)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # List all subdirectories (projects) in the current directory
        projects = builtins.filter
          (name: builtins.pathExists (./. + "/${name}/Cargo.toml"))
          (builtins.attrNames (builtins.readDir ./.));

        # Function to create a dev shell for a given project
        mkDevShell = project:
          let
            # Default to stable Rust if no rust-toolchain.toml exists
            rustToolchainPath = ./. + "/${project}/rust-toolchain.toml";
            overrides = if builtins.pathExists rustToolchainPath
              then builtins.fromTOML (builtins.readFile rustToolchainPath)
              else { toolchain = { channel = "stable"; }; };

            # Check if the project has a shell.nix file
            projectShellPath = ./. + "/${project}/shell.nix";
            projectShell = if builtins.pathExists projectShellPath
              then import projectShellPath { inherit pkgs; }
              else { };

            # Merge project-specific dependencies with the default ones
            buildInputs = (with pkgs; [
              clang
              llvmPackages.bintools
              rustup
              bacon
            ]) ++ (projectShell.buildInputs or [ ]);
          in
          pkgs.mkShell {
            inherit buildInputs;

            # Allow impure environment variables
            RUSTC_VERSION = overrides.toolchain.channel;
            LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];

            shellHook = ''
              # Initialize rustup if not already initialized
              if ! rustup toolchain list | grep -q "$RUSTC_VERSION"; then
                rustup toolchain install $RUSTC_VERSION
              fi
              rustup default $RUSTC_VERSION

              # Add Rust binaries to PATH
              export PATH=$PATH:${pkgs.rustup}/bin
              export PATH=$PATH:${pkgs.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
            '' + (projectShell.shellHook or "");
          };

        # Default dev shell for new projects
        defaultDevShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            clang
            llvmPackages.bintools
            rustup
          ];

          # Allow impure environment variables
          RUSTC_VERSION = "stable";
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];

          shellHook = ''
            # Initialize rustup if not already initialized
            if ! rustup toolchain list | grep -q "$RUSTC_VERSION"; then
              rustup toolchain install $RUSTC_VERSION
            fi
            rustup default $RUSTC_VERSION

            # Add Rust binaries to PATH
            export PATH=$PATH:${pkgs.rustup}/bin
            export PATH=$PATH:${pkgs.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';
        };
      in
      {
        # Create a dev shell for each project
        devShells = builtins.listToAttrs (map (project: {
          name = project;
          value = mkDevShell project;
        }) projects) // {
          # Add a default dev shell for new projects
          default = defaultDevShell;
        };
      }
    );
}
