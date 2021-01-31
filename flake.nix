{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # flutter 1.24
    unstable.url =
      "github:thiagokokada/nixpkgs/49a37a887c96d68e23993778e8330b1f36852473";
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
        flutterPiGitVersion = "133600ca46892e59b679f31378a7be1dc5aaa4d8";
        flutterPiGitHash =
          "sha256-c0OwXz6RwLaJd/VNigWHjsn46wLYDuMmros6o5QL0QA=";
        flutter_pi = import ./lib/flutter_pi.nix {
          pkgs = pkgs;
          engineHeaderVersion = engineHeaderVersion;
          engineHeaderHash = engineHeaderHash;
          flutterPiGitVersion = flutterPiGitVersion;
          flutterPiGitHash = flutterPiGitHash;
        };

      in rec {

        devShell = pkgs.mkShell { buildInputs = with pkgs; [ flutter_pi ]; };

        packages = { flutter_pi = flutter_pi; };

        defaultPackage = flutter_pi;
      }) // {
        helpers = {
          builder = import ./lib/builder.nix;
          config_gen = (import ./lib/config_gen.nix {
            flutter_pi = self.packages.aarch64-linux.flutter_pi;
          });
        };
      });
}
