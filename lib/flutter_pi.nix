{ pkgs, engineHeaderVersion, engineHeaderHash, flutterPiGitVersion
, flutterPiGitHash }:
let
  engine = pkgs.stdenv.mkDerivation {
    name = "flutter-engine";
    src = builtins.fetchurl {
      url =
        "https://raw.githubusercontent.com/flutter/engine/${engineHeaderVersion}/shell/platform/embedder/embedder.h";

      sha256 = engineHeaderHash;
    };
    #nativeBuildInputs = with pkgs; [ breakpointHook ];
    configurePhase = "true";
    buildPhase = "true";
    unpackPhase = "true";

    installPhase = ''
      mkdir -p $out/include
      cp $src $out/include/flutter_embedder.h
    '';

  };

in pkgs.stdenv.mkDerivation {
  name = "flutter-pi";
  src = pkgs.fetchgit {
    url = "https://github.com/ardera/flutter-pi.git";
    rev = flutterPiGitVersion;
    sha256 = flutterPiGitHash;
  };

  patches = [ ../patches/icu.patch ];

  buildInputs = with pkgs; [
    clang
    pkg-config
    libdrm
    mesa
    libGL
    systemd
    libinput
    libxkbcommon
    xorg.libX11
    cmake
  ];
  nativeBuildInputs = with pkgs; [
    engine
    pkg-config
    libdrm
    mesa
    libGL
    systemd
    libinput
    libxkbcommon
    xorg.libX11
    python38
    #breakpointHook
  ];

  configurePhase = ''
    cp ${engine}/include/flutter_embedder.h .
    cmake --trace  -D FLUTTER_EMBEDDER_HEADER=true   . 
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp flutter-pi $out/bin
              '';

}
