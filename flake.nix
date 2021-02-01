{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url = "github:nixos/nixpkgs/master";
  };
  outputs = { self, nixpkgs, flake-utils, unstable }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import unstable {
          system = system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        });
        engineHeaderVersion = "2f0af3715217a0c2ada72c717d4ed9178d68f6ed";
        engineHeaderHash =
          "sha256:1b12iys33b38ph4b7qgca4gys8lwda90xflg89kiv6vasj0nlk8a";
        flutterPiGitVersion = "ca624695700733e4403d90c1671506f1381d18d5";
        arm = "arm64";
        flutterPiGitHash =
          "sha256-ytHGM6fF2Rq15+lE+YtPADJ0CKHtC2kRpAT7vt0nERs=";
        engineBins = import ./lib/engine_bin.nix { inherit pkgs arm; };
        flutter_pi = import ./lib/flutter_pi.nix {
          inherit pkgs engineHeaderVersion engineHeaderHash flutterPiGitVersion
            flutterPiGitHash;
        };
        flutter_pi_wrapped = import ./lib/flutter_pi_wrapped.nix {
          inherit pkgs flutter_pi engineBins;

        };

      in rec {

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ flutter_pi ];
          shellHook = ''
            export ICU_DATA=${engineBins}
          '';
        };

        packages = {
          flutter_pi = flutter_pi;
          flutter_pi_wrapped = flutter_pi_wrapped;
          engineBins = engineBins;
        };
        defaultPackage = flutter_pi;
      }) // {
        helpers = {
          builder = import ./lib/builder.nix;
          config_gen = (import ./lib/config_gen.nix {
            flutter_pi = self.packages.aarch64-linux.flutter_pi;
            flutter_pi_wrapped = self.packages.aarch64-linux.flutter_pi_wrapped;
            engineBins = self.packages.aarch64-linux.engineBins;
          });
        };
      });
}
