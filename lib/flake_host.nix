{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    unstable.url =
      "github:thiagokokada/nixpkgs/49a37a887c96d68e23993778e8330b1f36852473";
    flutterpinixos.url =
      "git+https://github.com/PeterZainzinger/flutter-pi-nixos";

  };
  description = "flutter setup";
  outputs = { self, nixpkgs, flake-utils, unstable, flutterpinixos, }:
    (let
      cfg = import ./host_config.nix;
      hostName = cfg.hostName;
    in {
      nixosConfigurations."${hostName}" = let
        pi_config = flutterpinixos.helpers.config_gen {
          cfg = cfg;
          initial = false;
        };
      in nixpkgs.lib.makeOverridable nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ nixpkgs.nixosModules.notDetected pi_config ] ++ cfg.modules;
      };
    });
}
