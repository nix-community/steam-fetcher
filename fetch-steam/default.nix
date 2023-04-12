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
  buildInputs = [
    depotdownloader
  ];
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
