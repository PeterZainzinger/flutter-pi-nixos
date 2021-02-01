# passed by flake
{ flutter_pi, flutter_pi_wrapped, engineBins, ... }:
# passed from user 
# TODO(peter): ... needed?
{ initial ? false, cfg, ... }:
# module args
{ pkgs, lib ? pkgs.stdenv.lib, ... }:

# mkIf does not work for this??
(if initial then { sdImage.compressImage = false; } else { }) // ({

  systemd.user.services."app_release" = {
    enable = true;
    path = [ flutter_pi ];
    environment = {
      LD_LIBRARY_PATH = "${engineBins}";
      ICU_DATA = "${engineBins}/icudtl.dat";
    };
    serviceConfig = {
      ExecStartPre = "/run/current-system/sw/bin/sleep 10";
      ExecStart = "${flutter_pi}/bin/flutter-pi --release %h/app";
    };
    #    wantedBy = [ "multi-user.target " ];

  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [ "cma=256M" ];
    loader = {
      grub.enable = false;
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = true;
        firmwareConfig = ''
          gpu_mem=64
        '';
      };
    };
    cleanTmpDir = true;
    kernel = lib.mkIf (!initial) { sysctl."vm.overcommit_memory" = "1"; };
  };

  fileSystems = lib.mkIf (!initial) {
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };
  };

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware = {
    deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };
  };

  nix = {
    useSandbox = false;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  users = {
    mutableUsers = false;
    users.root.password = "peter";
    users.peter = {
      uid = 1000;
      password = "peter";
      isNormalUser = true;
      extraGroups =
        [ "wheel" "audio" "tty" "render" "pi" "video" "plugdev" "input" ];

    };

    extraUsers.root.openssh.authorizedKeys.keys = cfg.gen_config.sshPubKeys;

  };

  environment = {
    variables = { ICU_DATA = "${engineBins}/icudtl.dat"; };
    systemPackages = with pkgs; [
      raspberrypi-tools
      flutter_pi
      flutter_pi_wrapped
      engineBins
    ];
    etc = {
      "nixos/flake.nix" = {
        source = ./flake_host.nix;
        mode = "0660";
        user = "root";
      };
      "nixos/host_config.nix" = {
        source = cfg.self;
        mode = "0660";
        user = "root";
      };
    };
  };

  networking = {
    hostName = cfg.hostName;
    useDHCP = false;
    interfaces = {
      eth0.useDHCP = true;
      wlan0.useDHCP = true;
    };
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = true;
    };
  };

  system.stateVersion = "20.03";

})
