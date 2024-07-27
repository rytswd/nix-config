{ pkgs
, lib
, config
, ...}:

{
  options = {
    linux-widget.bemoji.enable = lib.mkEnableOption "Enable bemoji, emoji picker.";
  };

  config = lib.mkIf config.linux-widget.bemoji.enable {
    home.packages = [
      pkgs.bemoji
    ];
  };
}
