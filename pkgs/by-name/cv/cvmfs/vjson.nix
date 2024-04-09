{
  stdenv,
  cmake,
  fetchzip,
  src,
  version,
}:
stdenv.mkDerivation {
  pname = "cvmfs-vjson";
  version = "${version}-vendored";

  src = "${src}/externals/vjson/src";

  buildPhase = ''
    runHook preBuild

    $CXX -I. -c -o json.o json.cpp
    $CXX -I. -c -o block_allocator.o block_allocator.cpp
    $CXX json.o block_allocator.o -shared -o libvjson.so

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{include,lib}
    cp json.h block_allocator.h $out/include
    cp libvjson.so $out/lib

    runHook postInstall
  '';
}
