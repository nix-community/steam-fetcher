{
  lib,
  stdenv,
  fetchSteam,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  name = "steamworks-sdk-redist";
  version = "18639946";
  src = fetchSteam {
    inherit name;
    appId = "1007";
    depotId = "1006";
    manifestId = "6912453647411644579";
    hash = "sha256-V1CAYHAFz/TRUyJU8m6Jf/LlM6d9QhGZt6VKAoNn5Ho=";
  };

  # Skip phases that don't apply to prebuilt binaries.
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    # Install only the binary matching the target platform.
    ${lib.optionalString (stdenv.targetPlatform.system == "i686-linux")
      "cp steamclient.so $out/lib"}
    ${lib.optionalString (stdenv.targetPlatform.system == "x86_64-linux")
      "cp linux64/steamclient.so $out/lib"}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steamworks SDK shared library";
    homepage = "https://steamdb.info/app/1007/";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [aidalgol];
    platforms = ["i686-linux" "x86_64-linux"];
  };
}
