{
  lib,
  stdenvNoCC,
  depotdownloader,
  cacert,
  writeText,
}: {
  name,
  debug ? false,
  appId,
  depotId,
  manifestId,
  branch ? null,
  fileList ? [],
  hash,
}: let
  fileListFile = let
    content = lib.concatStringsSep "\n" fileList;
  in
    writeText "steam-file-list-${name}.txt" content;
in
  stdenvNoCC.mkDerivation {
    name = "${name}-depot";
    inherit debug appId depotId manifestId branch;
    filelist =
      if fileList != []
      then fileListFile
      else null;
    builder = ./builder.sh;
    buildInputs = [
      depotdownloader
    ];
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    outputHash = hash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  }
