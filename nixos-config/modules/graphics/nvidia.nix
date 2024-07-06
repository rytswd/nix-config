{ pkgs
, lib
, config
, ...}:

{
  options = {
    graphics.nvidia-offload.enable = lib.mkEnableOption "Set up NVIDIA GPU with offloading.";
  };

  # NOTE: This setup is to use built-in GPU for most tasks, and NVIDIA GPU can
  # be used for offloading.
  config = lib.mkIf config.graphics.nvidia-offload.enable {
    # Ref https://nixos.wiki/wiki/Nvidia
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:101:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # This adds nvidia offload
    services.xserver.videoDrivers = ["nvidia"];
  };
}
