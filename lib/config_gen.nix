{ pkgs, lib ? pkgs.stdenv.lib,
#sshPubKeys ? [ ],
... }: {

  sdImage.compressImage = false;

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
    #kernel = { sysctl."vm.overcommit_memory" = "1"; };
  };

  #fileSystems."/" = {
  #  device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
  #  fsType = "ext4";
  #};
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
      extraGroups = [ "wheel" "audio" "tty" "render" "pi" "video" ];

    };

    #extraUsers.root.openssh.authorizedKeys.keys = sshPubKeys;

  };

  environment.systemPackages = with pkgs; [
    wget
    vim
    curl
    git
    raspberrypi-tools
  ];

  networking = {
    hostName = "pi3";
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

}
