{
  lib,
  fetchFromCodeberg,
  melpaBuild,
  pkg-config,
  mupdf-headless,
}:

melpaBuild {
  ename = "reader";
  pname = "emacs-reader";
  version = "0-unstable-2026-08-31";

  src = fetchFromCodeberg {
    owner = "divyaranjan";
    repo = "emacs-reader";
    rev = "a0e3615adbf520a5743bbbfd7da6d2bb8478b30b";
    hash = "sha256-wLtTuNPVDVGVa0fhC57DJfXjTFp2itxXJfw/XqgZUQQ=";
  };

  makeFlags = [
    "USE_PKGCONFIG=yes"
  ];

  files = ''(:defaults "render-core.so")'';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ mupdf-headless ];
  preBuild = ''
    make all
  '';

  meta = {
    homepage = "https://codeberg.org/divyaranjan/emacs-reader";
    description = "An all-in-one document reader for all formats in Emacs, backed by MuPDF";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ viperML ];
  };
}
