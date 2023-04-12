{
  lib,
  stdenvNoCC,
  depotdownloader,
  cacert,
}: {
  name,
  debug ? false,
  appId,
  depotId,
  manifestId,
  branch ? null,
  hash,
}:
stdenvNoCC.mkDerivation {
  name = "${name}-depot";
  inherit debug appId depotId manifestId branch;
  builder = ./builder.sh;
  buildInputs = [
    depotdownloader
  ];
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  outputHash = hash;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
