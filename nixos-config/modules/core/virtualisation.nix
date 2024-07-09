{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.virtualisation.docker.enable = lib.mkEnableOption "Enable docker.";
  };

  config = lib.mkIf config.core.virtualisation.docker.enable {
    virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
