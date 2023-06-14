{
  description = "Nix fether for Steam games";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    with flake-utils.lib;
    # DepotDownloader only supports x86_64 Linux.
      eachSystem ["x86_64-linux"] (system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
        };

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

        checks =
          builtins.mapAttrs (name: pkgs.runCommandLocal name {nativeBuildInputs = linters;}) {
            alejandra = "alejandra --check ${./.} > $out";
            shellcheck = "shellcheck $(${pkgs.shfmt}/bin/shfmt --find ${./.}) > $out";
            shfmt = "shfmt --simplify --diff ${./.} > $out";
            statix = "statix check ${./.} > $out";
          }
          // {
            inherit (pkgs) steamworks-sdk-redist;
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
