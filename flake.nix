{
  description = "Nix fether for Steam games";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    with flake-utils.lib;
      eachDefaultSystem (system: let
        pkgs = import nixpkgs {inherit system;};

        linters = with pkgs; [
          alejandra
          statix
          shellcheck
          shfmt
        ];
      in {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs;
              [
                nil # Nix LS
                nodePackages.bash-language-server
              ]
              ++ linters;
          };
        };

        checks = builtins.mapAttrs (name: pkgs.runCommandLocal name {nativeBuildInputs = linters;}) {
          alejandra = "alejandra --check ${./.} > $out";
          shellcheck = "shellcheck $(${pkgs.shfmt}/bin/shfmt --find ${./.}) > $out";
          shfmt = "shfmt --simplify --diff ${./.} > $out";
          statix = "statix check ${./.} > $out";
        };

        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = linters;
          text = ''
            alejandra --quiet .
            statix fix .
            shfmt --simplify --write .
          '';
        };
      })
      // {
        overlays.default = final: prev: {
          fetchSteam = final.callPackage ./fetch-steam {};
          steamworks-sdk-redist = final.callPackage ./steamworks-sdk-redist {};
        };
      };
}
