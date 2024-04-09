{
  stdenv,
  lib,
  src,
  version,
}:
stdenv.mkDerivation {
  pname = "cvmfs-protobuf";
  version = "${version}-vendored";

  src = "${src}/externals/protobuf/protobuf-2.6.1.tar.bz2";
}
