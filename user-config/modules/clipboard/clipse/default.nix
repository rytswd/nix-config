{ pkgs
, lib
, config
, ...}:

{
  options = {
    clipboard.clipse.enable = lib.mkEnableOption "Enable clipse.";
  };

  config = lib.mkIf config.clipboard.clipse.enable {
    home.packages = [
      pkgs.clipse
    ];
    xdg.configFile = {
      "clipse/config.json".source = ./config.json;
    };
  };
}
