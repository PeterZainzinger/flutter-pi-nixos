{ pkgs, ... }:
let gpuMemory = "64";
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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
          gpu_mem=${gpuMemory}
        '';
      };
    };
    cleanTmpDir = true;
    kernel = { sysctl."vm.overcommit_memory" = "1"; };
  };

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

