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
          config = { allowUnfree = true; };
        });

      in {

        devShell = pkgs.mkShell {
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
            cntr
          ];
          nativeBuildInputs = with pkgs; [
            pkg-config
            libdrm
            mesa
            libGL
            systemd
            libinput
            libxkbcommon
            xorg.libX11
            python38
            breakpointHook
          ];

          #shellHook = "";
        };

        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "flutter-pi";
          src = pkgs.fetchgit {
            url = "https://github.com/ardera/flutter-pi.git";
            rev = "133600ca46892e59b679f31378a7be1dc5aaa4d8";
            sha256 = "sha256-c0OwXz6RwLaJd/VNigWHjsn46wLYDuMmros6o5QL0QA=";
          };

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
            pkg-config
            libdrm
            mesa
            libGL
            systemd
            libinput
            libxkbcommon
            xorg.libX11
            python38
            breakpointHook
          ];

          configurePhase = ''
            cmake --trace . 
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
