{ pkgs
, lib
, config
, ...}:

{
  options = {
    terminal.kitty.enable = lib.mkEnableOption "Enable Kitty.";
  };

  config = lib.mkIf config.terminal.kitty.enable {
    programs.kitty = {
      enable = true;
    };
  };
}
