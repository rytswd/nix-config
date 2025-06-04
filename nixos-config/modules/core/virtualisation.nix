{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.virtualisation.docker.enable = lib.mkEnableOption "Enable docker.";
  };

  config = lib.mkIf config.core.virtualisation.docker.enable {
    virtualisation = {
      docker = {
        enable = true;
        # NOTE: When using rootless Docker, I cannot make it work with GPU, such
        # as using it with Ollama.
        # rootless = {
        #   enable = true;
        #   setSocketVariable = true;
        # };
      };
      podman = {
        enable = true;
      };
    };
  };
}
