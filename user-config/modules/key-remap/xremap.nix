{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    key-remap.xremap.enable = lib.mkEnableOption "Enable xremap.";
  };

  imports = [ inputs.xremap.homeManagerModules.default ];

  config = lib.mkIf config.key-remap.xremap.enable {
    services.xremap = {
      enable = true;
      withWlroots = true;
      watch = true;
      deviceNames = [
        "Asus\ Keyboard"
      ];
      yamlConfig = (builtins.readFile ./xremap.yaml);
    };
  };
}
