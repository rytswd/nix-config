{ pkgs
, lib
, config
, ...}:

# Ref: https://ollama.dev/

{
  options = {
    service.ollama.enable = lib.mkEnableOption "Enable Ollama related tooling.";
  };

  config = lib.mkIf config.service.ollama.enable {
    home.packages = [
      pkgs.ollama-vulkan
    ];

    # NOTE: Due to the laptop sleep handling, I could see a random error of:
    #
    #     cuda driver library init failure: 999.
    #
    # In case of this error, I just need to run the following command:
    #
    #     sudo rmmod nvidia_uvm; sudo modprobe nvidia_uvm
    #
    # However, this assumes there is no other GPU usage, or if they are, they
    # could be safely killed with the above command.

    # NOTE: Because of the nvidia-offload setup, the setup below needed tweak.
    # Following some recent changes, it seems unnecessary, and most parts are
    # commented out for now.

    services.ollama = {
      enable = true;

      # NOTE: Due to some broken cuda version, I'm using vulkan instead.
      package = pkgs.ollama-vulkan;
      # package = pkgs.ollama-cuda;
      # acceleration = "cuda";

      # environmentVariables = {
      #   # NOTE: The below env mimics the use of nvidia-offload.
      #   __NV_PRIME_RENDER_OFFLOAD = "1";
      #   __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
      #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #   __VK_LAYER_NV_optimus = "NVIDIA_only";
      # };
    };

    # # Update the exec to effectively use nvidia-offload.
    # systemd.user.services.ollama = {
    #   # NOTE: The below env mimics the use of nvidia-offload.
    #   environment = {
    #     __NV_PRIME_RENDER_OFFLOAD = "1";
    #     __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    #     __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #     __VK_LAYER_NV_optimus = "NVIDIA_only";
    #   };
    # };
  };
}
