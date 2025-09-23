{
  description = "vs-overlay";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      # DepotDownloader only supports x86_64 Linux.
      systems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
          config.allowUnfree = true;
        }
      );
    in
    {
      overlay = import ./default.nix;
      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) steamworks-sdk-redist;
      });
    };
}
