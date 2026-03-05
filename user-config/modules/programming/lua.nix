{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.lua.enable = lib.mkEnableOption "Enable Lua related tools.";
  };

  config = lib.mkIf config.programming.lua.enable {
    home.packages = [
      pkgs.lua-language-server
    ];
  };
}
