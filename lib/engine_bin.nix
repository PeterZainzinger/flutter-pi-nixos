{ pkgs, arm, }:

pkgs.stdenv.mkDerivation {
  name = "flutter-engine-bins-${arm}";
  version = "1.22.5";
  src = pkgs.fetchgit {
    url = "https://github.com/ardera/flutter-pi";
    rev = "eb4ce022e03a9c971874ed0328613f93304e2bf4";
    sha256 = "sha256-FSYdSGtFtQESXvgXBHK+oBYvQUXr8SBBlwW66HMIvW8=";
  };
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  configurePhase = "true";
  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/
    cp -r $src/${arm}/* $out/
    chmod +x $out/gen_snapshot_linux_x64
  '';
  preFixup = ''
    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/gen_snapshot_linux_x64
  '';

}

