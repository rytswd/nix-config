{ pkgs
, lib
, config
, ...}:

{
  options = {
    graphics.standard.enable = lib.mkEnableOption "Enable standard GPU setup.";
  };

  config = lib.mkIf config.graphics.standard.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      # extraPackages = [ pkgs.virglrenderer ];
    };
  };
}
