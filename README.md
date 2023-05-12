# Steam Nix fetcher
## `fetchSteam`
This flake contains the function `fetchSteam`.  This is a Nix fetcher for Steam apps that wraps [DepotDownloader](https://github.com/SteamRE/DepotDownloader) from [nixpkgs](https://search.nixos.org/packages?query=depotdownloader).  While this could theoretically be used for installing Steam games on a graphical system, it is aimed at NixOS modules for game servers distributed via Steam.

## Steamworks SDK Redist
This flake also contains a package for the [Steamworks SDK Redist(ributable)](https://steamdb.info/app/1007/depots/), which is a dependency of any game server that uses the Steamworks API.

## Usage
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
      *.so \
      some_server_executable \
      some_server_game_data \
      $out

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
