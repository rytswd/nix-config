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
      pkgs.ollama-cuda
    ];

    services.ollama = {
      enable = true;
      acceleration = "cuda";
    };

    # Update the exec to effectively use nvidia-offload.
    systemd.user.services.ollama = {
      # NOTE: Due to the laptop sleep handling, I could see a random error of:
      #
      #     cuda driver library init failure: 999.
      #
      # In case of this error, I just need to run the following command:
      #
      #     sudo rmmod nvidia_uvm; sudo modprobe nvidia_uvm
      environment = {
        __NV_PRIME_RENDER_OFFLOAD = "1";
        __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __VK_LAYER_NV_optimus = "NVIDIA_only";
      };
    };
  };
}
