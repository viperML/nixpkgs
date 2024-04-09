{ stdenv, src, version }:
stdenv.mkDerivation {
  name = "cvmfs-sha3";
  version = "${version}-vendored";

  src = "${src}/externals/sha3/src";

  buildPhase = ''
    runHook preBuild

    export EXTERNALS_INSTALL_LOCATION=$out
    mkdir -p $out/{include,lib}

    bash ./makeHook.sh

    runHook postBuild
  '';

  dontInstall = true;
}
