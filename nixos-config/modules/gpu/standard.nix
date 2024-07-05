{ pkgs
, lib
, config
, ...}:

{
  options = {
    gpu.standard.enable = lib.mkEnableOption "Enable standard GPU setup.";
  };

  config = lib.mkIf config.gpu.standard.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # extraPackages = [ pkgs.virglrenderer ];
    };
  };
}
