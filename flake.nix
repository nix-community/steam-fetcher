{
  description = "Nix fether for Steam games";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    # DepotDownloader only supports x86_64 Linux.
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [self.overlays.default];
      };
    lintersFor = system: let
      pkgs = pkgsFor system;
    in
      with pkgs; [
        alejandra
        statix
        shellcheck
        shfmt
      ];
  in {
    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = with pkgs;
          [
            nil # Nix LS
            nodePackages.bash-language-server
          ]
          ++ (lintersFor system);
      };
    });

    checks = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      builtins.mapAttrs (name: pkgs.runCommandLocal name {nativeBuildInputs = lintersFor system;}) {
        alejandra = "alejandra --check ${./.} > $out";
        shellcheck = "shellcheck $(${pkgs.shfmt}/bin/shfmt --find ${./.}) > $out";
        shfmt = "shfmt --simplify --diff ${./.} > $out";
        statix = "statix check ${./.} > $out";
      }
      // {
        inherit (pkgs) steamworks-sdk-redist;
      });

    formatter = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      pkgs.writeShellApplication {
        name = "fmt";
        runtimeInputs = lintersFor system;
        text = ''
          alejandra --quiet .
          statix fix .
          shfmt --simplify --write .
        '';
      });

    overlays.default = final: prev: let
      pkgs = pkgsFor final.system;
    in rec {
      fetchSteam = final.callPackage ./fetch-steam {inherit (pkgs) depotdownloader;};
      steamworks-sdk-redist = final.callPackage ./steamworks-sdk-redist {};
    };

    packages = forAllSystems (system: let
      pkgs = pkgsFor system;
    in rec {
      inherit (pkgs) steamworks-sdk-redist;
    });
  };
}
