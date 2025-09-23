let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  packages = [
    pkgs.nixfmt-rfc-style
    pkgs.just
    pkgs.shellcheck
    pkgs.shfmt
  ];
}
