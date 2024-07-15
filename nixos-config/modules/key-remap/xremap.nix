{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.xremap.nixosModules.default ];
  options = {
    key-remap.xremap.enable = lib.mkEnableOption "Enable xremap.";
  };

  config = lib.mkIf config.key-remap.xremap.enable {
    services.xremap = {
      enable = true;
      withWlroots = true;
      # withHypr = true;
      watch = true;
      # yamlConfig = (builtins.readFile ./xremap.yaml);
    };
  };
}
