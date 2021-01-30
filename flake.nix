{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # flutter 1.24
    unstable.url =
      "github:thiagokokada/nixpkgs/49a37a887c96d68e23993778e8330b1f36852473";
  };
  outputs = { self, nixpkgs, flake-utils, unstable }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import unstable {
          system = system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        });
        engineVersion = "2f0af3715217a0c2ada72c717d4ed9178d68f6ed";
        engineHeaderHash =
          "sha256:1b12iys33b38ph4b7qgca4gys8lwda90xflg89kiv6vasj0nlk8a";
        flutterPiGitVersion = "133600ca46892e59b679f31378a7be1dc5aaa4d8";
        flutterPiGitHash =
          "sha256-c0OwXz6RwLaJd/VNigWHjsn46wLYDuMmros6o5QL0QA=";

      in rec {

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ python38 defaultPackage ];
        };

        defaultPackage = let
          engine = pkgs.stdenv.mkDerivation {
            name = "flutter-engine";
            src = builtins.fetchurl {
              url =
                "https://raw.githubusercontent.com/flutter/engine/${engineVersion}/shell/platform/embedder/embedder.h";

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

          patches = [ ./icu.patch ];

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
            python38
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

        };
      });
}
