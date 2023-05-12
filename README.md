# Steam Nix fetcher
## `fetchSteam`
This flake contains the function `fetchSteam`.  This is a Nix fetcher for Steam apps that wraps [DepotDownloader](https://github.com/SteamRE/DepotDownloader) from [nixpkgs](https://search.nixos.org/packages?query=depotdownloader).  While this could theoretically be used for installing Steam games on a graphical system, it is aimed at NixOS modules for game servers distributed via Steam.

## Steamworks SDK Redist
This flake also contains a package for the [Steamworks SDK Redist(ributable)](https://steamdb.info/app/1007/depots/), which is a dependency of any game server that uses the Steamworks API.

## Usage
Let's say you want to set up a server for a new game called *Junkyard* on NixOS, but the game server is only distributed via Steam, and no one has yet written a NixOS module for it, so you're going to be the one to do it.  You create a new git repository named `junkyard-server-flake` and start with a package definition at `pkgs/junkyard-server/default.nix`.
```nix
{
  lib,
  stdenv,
  fetchSteam,
}:
stdenv.mkDerivation rec {
  name = "some-server";
  version = "x.y.z";
  src = fetchSteam {
    inherit name;
    appId = "xyz";
    depotId = "xyz";
    manifestId = "xyz";
    # Fetch a different branch. <https://partner.steamgames.com/doc/store/application/branches>
    # branch = "beta_name";
    # Enable debug logging from DepotDownloader.
    # debug = true;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # Skip phases that don't apply to prebuilt binaries.
  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r \
      # list of files at the top level to copy
      $out

    # You may need to fix permissions on the main executable.
    chmod +x $out/some_server_executable

    runHook postInstall
  '';

  meta = with lib; {
    description = "Some dedicated server";
    homepage = "https://steamdb.info/app/xyz/";
    changelog = "https://store.steampowered.com/news/app/xyz?updates=true";
    sourceProvenance = with sourceTypes; [
      binaryNativeCode # Steam games are always going to contain some native binary component.
      binaryBytecode # e.g. Unity games using C#
    ];
    license = licenses.unfree;
    platforms = ["x86_64-linux"];
  };
}
```
You could try using [`autoPatchelfHook`](https://nixos.org/manual/nixpkgs/unstable/#setup-hook-autopatchelfhook) in the above derivation, but in this example, we are going to define a FHS environment wrapper in `pkgs/junkyard-server/fhsenv.nix`.
```nix
{
  lib,
  buildFHSUserEnv,
  writeScript,
  junkyard-server-unwrapped,
  steamworks-sdk-redist,
}:
buildFHSUserEnv {
  name = "junkyard-server";

  runScript = "junkyard-server-executable";

  targetPkgs = pkgs: [
    junkyard-server-unwrapped
    steamworks-sdk-redist
  ];

  inherit (junkyard-server-unwrapped) meta;
}
```
Now for the `flake.nix`.
```nix
{
  description = "NixOS module for the Junkyard dedicated server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    steam-fetcher = {
      url = "github:aidalgol/nix-steam-fetcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    steam-fetcher,
  }: {
    nixosModules = rec {
      junkyard = import ./nixos-modules/junkyard.nix {inherit self steam-fetcher;};
      default = junkyard;
    };
    overlays.default = final: prev: {
      junkyard-server-unwrapped = final.callPackage ./pkgs/junkyard-server {};
      junkyard-server = final.callPackage ./pkgs/junkyard-server/fhsenv.nix {};
    };
  };
}
```
Before moving on to the NixOS module, we need to explain the pattern used here.  The `nixosModules` attrset in a flake does is not scoped to system type, unlike a flake's `packages` attrset, so we cannot pass packages into the derivation that returns a module.  Instead, we must pass this flake and the `steam-fetcher` flake.  The module will then apply the overlays to `config.nixpkgs.overlays`, which makes the packages available via the `pkgs` argument passed to the module when this flake is used in a NixOS system configuraiton (of which we will provide an example later).

Now we create `nixos-modules/junkyard.nix`.
```nix
{
  self,
  steam-fetcher,
}: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.junkyard;
in {
  config.nixpkgs.overlays = [self.overlays.default steam-fetcher.overlays.default];

  options.services.junkyard = {
    enable = lib.mkEnableOption (lib.mdDoc "Junkyard Dedicated Server");

    port = lib.mkOption {
      type = lib.types.port;
      default = 9001;
      description = lib.mdDoc "The port on which to listen for incoming connections.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Whether to open ports in the firewall.";
    };

    # Any options you want to expose for the game server, which will vary from game to game.
  };

  config = {
    users = {
      users.junkyard = {
        isSystemUser = true;
        group = "junkyard";
        home = stateDir;
      };
      groups.junkyard = {};
    };

    systemd.services.junkyard = {
      description = "Junkyard dedicated server";
      requires = ["network.target"];
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
          Type = "exec";
          User = "junkyard";
          ExecStart = "${pkgs.junkyard-server}/junkyard-server-executable";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedUDPPorts = [
        cfg.port
        (cfg.port + 1) # Steam server browser
      ];
    };
  };
}
```
Now to use it in a NixOS configuration.
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    junkyard-server = {
      url = "github:aidalgol/junkyard-server-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    junkyard-server,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosConfigurations.my-server= nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        junkyard-server.nixosModules.default
      ];
    };
  };
}
```
Then in `./configuration.nix`,
```nix
{
  config,
  pkgs,
  ...  
}: {
  # ...
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "junkyard-server"
      "steamworks-sdk-redist"
    ];
  # ...
  services.junkyard = {
    enable = true;
    # Any other options.
    openFirewall = true;
  };
  # ...
}
```
