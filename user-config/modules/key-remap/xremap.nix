{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.xremap.homeManagerModules.default ];
  options = {
    key-remap.xremap.enable = lib.mkEnableOption "Enable xremap.";
  };

  config = lib.mkIf config.key-remap.xremap.enable {
    services.xremap = {
      enable = true;
      withWlroots = true;
      watch = true;
      yamlConfig = ./xremap.yaml;
    };
  };
}
