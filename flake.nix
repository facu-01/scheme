{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  # https://devenv.sh/reference/options/

                  packages = [
                    pkgs.mitscheme
                    pkgs.python311Packages.jupyterlab
                    pkgs.python311Packages.jupyter
                    pkgs.python311Packages.jupyter-core
                    pkgs.jupyter
                    pkgs.racket
                    pkgs.zeromq
                  ];

                  enterShell = ''
                    raco pkg install iracket
                    raco iracket install
                    jupyter-lab
                  '';

                }
              ];
            };
          });
    };
}
