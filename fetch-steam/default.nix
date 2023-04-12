{
  lib,
  stdenvNoCC,
  depotdownloader,
}: {
  name,
  appId,
  depotId,
  manifestId,
  branch ? null,
  hash,
}:
stdenvNoCC.mkDerivation {
  name = "${name}-depot";
  builder = ./builder.sh;
  nativeBuildInputs = [
    depotdownloader
  ];

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
