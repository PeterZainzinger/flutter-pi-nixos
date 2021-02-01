{ pkgs, arm, }:

pkgs.stdenv.mkDerivation {
  name = "flutter-engine-bins-${arm}";
  version = "1.22.4";
  src = pkgs.fetchgit {
    url = "https://github.com/ardera/flutter-pi";
    rev = "341288caed5ef3450ed545e196733fee0cf6a568";
    sha256 = "sha256-/5gqLOtpLlh5CW1I/uEOZTb17rM0c2igngNfSs3LlPA=";
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

