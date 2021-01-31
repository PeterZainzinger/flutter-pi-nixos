{ pkgs, flutter_pi, engineBins, }:
pkgs.writeShellScriptBin "flutter-pi-wrapped" ''
  LD_LIBRARY_PATH=${engineBins} flutter-pi  "$@"
    ''

