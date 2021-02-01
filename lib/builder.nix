{ engineBins, }:
{ pkgs, flutter ? pkgs.flutter, src, package, name ? package
, mainPath ? "main.dart", arm ? "arm64", home ? "/tmp", ... }:
pkgs.stdenv.mkDerivation {
  inherit name src;

  buildInputs = [ flutter engineBins ];

  FLUTTER_SDK = "${flutter.unwrapped}";

  buildPhase = ''
    export HOME=${home}
    flutter packages get
    ${engineBins.out}/gen_snapshot_linux_x64 --help

    flutter build bundle --no-tree-shake-icons --precompiled
    ${flutter.unwrapped}/bin/cache/dart-sdk/bin/dart\
      ${flutter.unwrapped}//bin/cache/dart-sdk/bin/snapshots/frontend_server.dart.snapshot\
      --sdk-root ~/.cache/flutter/artifacts/engine/common/flutter_patched_sdk_product\
      --target=flutter\
      --aot --tfa -Ddart.vm.product=true\
      --packages .packages --output-dill build/kernel_snapshot.dill --depfile build/kernel_snapshot.d package:${package}/${mainPath}

    ${engineBins.out}/gen_snapshot_linux_x64 \
      --causal_async_stacks --deterministic --snapshot_kind=app-aot-elf \
      --strip  \
      --elf=build/flutter_assets/app.so build/kernel_snapshot.dill
              '';

  installPhase = ''
    mkdir -p $out/
    cp -r build/flutter_assets/* $out/
              '';

}
