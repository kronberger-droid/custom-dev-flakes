{
  description = "Environment with named dev environments and inherited shell specs.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
          python-lsp-server
          selenium
        ]))
        pkgs.geckodriver
        pkgs.firefox
        agenix.packages.${system}.default
      ];
      shellHook = ''
        if [[ -f /run/secrets/cms-pswd ]]; then
          export CMS_PSWD=$(cat /run/secrets/cms-pswd)
        else
         echo "Secret not found!"
        fi
      '';
    };
  };
}
