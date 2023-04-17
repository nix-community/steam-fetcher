# Steam Nix fetcher
## `fetchSteam`
This flake contains the function `fetchSteam`.  This is a Nix fetcher for Steam apps that wraps [DepotDownloader](https://github.com/SteamRE/DepotDownloader) from [nixpkgs](https://search.nixos.org/packages?query=depotdownloader).  While this could theoretically be used for installing Steam games on a graphical system, it is aimed at NixOS modules for game servers distributed via Steam.

## Steamworks SDK Redist
This flake also contains a package for the [Steamworks SDK Redist(ributable)](https://steamdb.info/app/1007/depots/), which is a dependency of any game server that uses the Steamworks API.

## Usage
This flake was written for the [Valheim Dedicated Server flake](https://github.com/aidalgol/valheim-server-flake), which can be referred to as an example for using this flake.
