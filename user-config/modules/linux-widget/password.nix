{ pkgs
, lib
, config
, ...}:

{
  options = {
    linux-widget.password.enable = lib.mkEnableOption "Enable password related tools.";
  };

  config = lib.mkIf config.linux-widget.password.enable {
    home.packages = [
      pkgs.gnome.seahorse
    ];
  };
}
