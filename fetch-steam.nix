{
  lib,
  runCommand,
  depotdownloader,
}: {
  name,
  appId,
  depotId,
  manifestId,
  branch ? null,
  hash,
}:
runCommand "${name}-depot" {
  buildInputs = [depotdownloader];
  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
} ''
  HOME="$out/fakehome"
  DepotDownloader \
    -app "${appId}" \
    -depot "${depotId}" \
    -manifest "${manifestId}" \
    ${lib.optionalString (branch != null) "-branch \"${branch}\""} \
    -dir "$out"
''
