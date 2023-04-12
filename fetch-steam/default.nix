{
  lib,
  stdenvNoCC,
  depotdownloader,
  cacert,
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
  inherit appId depotId manifestId branch;
  builder = ./builder.sh;
  nativeBuiltInputs = [
    cacert
  ];
  buildInputs = [
    depotdownloader
  ];

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
