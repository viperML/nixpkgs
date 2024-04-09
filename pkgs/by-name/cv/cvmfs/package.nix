{
  stdenv,
  fetchFromGitHub,
  cmake,
  libressl,
  gtest,
  python3,
  cpio,
  zlib,
  libuuid,
  pkg-config,
  lib,
  fuse,
  libcap,
  unzip,
  curl,
  libarchive,
  c-ares,
  callPackage,
  sqlite,
  leveldb,
  pacparser,
  sparsehash,
}:
stdenv.mkDerivation (
  final: {
    pname = "cvmfs";
    version = "2.11.2";

    src = lib.cleanSource /home/ayats/Documents/cvmfs;

    # src = fetchFromGitHub {
    #   owner = "cvmfs";
    #   repo = "cvmfs";
    #   rev = "cvmfs-${final.version}";
    #   hash = "sha256-0cHcccASTNmOoDXCpNwcXeNTkr2ZfQCN3uYG4MENq8E=";
    # };
    # patches = [./build.patch];

    cmakeFlags = [
      # less stuff to fix
      "-DBUILD_GEOAPI=OFF"
      # they bundle libs
      "-DBUILTIN_EXTERNALS=OFF"
    ];

    nativeBuildInputs = [
      cmake
      (python3.withPackages (p: [ p.setuptools ]))
      cpio
      pkg-config
      unzip
    ];

    buildInputs = [
      libressl
      zlib
      libuuid
      fuse
      libcap
      gtest
      libarchive
      c-ares
      final.passthru.sha3
      final.passthru.vjson
      curl
      sqlite
      final.passthru.protobuf
      leveldb
      pacparser
      sparsehash
    ];

    # hardeningDisable = [ "format" ];
    hardeningDisable = [ "all" ];

    env.UUID_LIBRARY_DIR = "${libuuid.dev}/include";

    passthru = {
      sha3 = callPackage ./sha3.nix { inherit (final) version src; };
      vjson = callPackage ./vjson.nix { inherit (final) version src; };
      protobuf = callPackage ./protobuf.nix { inherit (final) version src; };
    };

    env = {
      CXXFLAGS = "-fpermissive";
    };
  }
)
