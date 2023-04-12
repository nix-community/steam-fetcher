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

  buildInputs = [
    depotdownloader
  ];

  builder = ''
    HOME="$out/fakehome"
    DepotDownloader \
      -app "${appId}" \
      -depot "${depotId}" \
      -manifest "${manifestId}" \
      ${lib.optionalString (branch != null) "-branch \"${branch}\""} \
      -dir "$out"
  '';

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
