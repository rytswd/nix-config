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

      # NOTE: .stable with ‘nvidia-x11-560.35.03-6.12.1’ was marked broken with
      # Linux kernel 6.12.
      # I fell back to production version which was working correctly.
      # https://github.com/NixOS/nixpkgs/pull/358235
      # https://github.com/NixOS/nixpkgs/commit/8653ea453d81a7320c63f930911bcd9f7e063c65
      # This has been reverted after confirming that the no package override is
      # necessary in the later update.
      # package = config.boot.kernelPackages.nvidiaPackages.production;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # TODO: This is highly device dependent and should be configured
        # separately. The Bus ID can be found with the following command:
        #
        #     sudo lshw -C display
        #
        amdgpuBusId = "PCI:101:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # This adds nvidia offload
    services.xserver.videoDrivers = ["nvidia"];

    # Ensure Docker can make use of GPU.
    hardware.nvidia-container-toolkit.enable = true;

    environment.systemPackages = [
      pkgs.nvitop       # https://github.com/XuehaiPan/nvitop
    ];
  };
}
