{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.swapdir.homeModules.swapdir ];
  options = {
    shell.swapdir.enable = lib.mkEnableOption "Enable swapdir.";
  };

  config = lib.mkIf config.shell.swapdir.enable {
    programs.swapdir = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
