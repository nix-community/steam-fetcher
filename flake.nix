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

        # Generate a user-friendly version number.
        version = builtins.substring 0 8 self.lastModifiedDate;

        linters = with pkgs; [
          alejandra
          statix
        ];
      in {
        packages.fetchSteam = {
          name,
          appId,
          depotId,
          manifestId,
          branch ? null,
          hash,
        }:
          pkgs.runCommand "${name}-depot" {
            buildInputs = [pkgs.depotdownloader];
            outputHash = hash;
            outputHashAlgo = "sha256";
            outputHashMode = "recursive";
          } ''
            HOME="$out/fakehome"
            DepotDownloader \
              -app "${appId}" \
              -depot "${depotId}" \
              -manifest "${manifestId}" \
              ${pkgs.lib.optionalString (branch != null) "-branch \"${branch}\""} \
              -dir "$out"
          '';

        checks = builtins.mapAttrs (name: pkgs.runCommandLocal name {nativeBuildInputs = linters;}) {
          alejandra = "alejandra --check ${./.} > $out";
          statix = "statix check ${./.} > $out";
        };

        formatter = pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = linters;
          text = ''
            alejandra --quiet .
            statix fix .
          '';
        };
      });
}