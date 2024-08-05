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
      # NOTE: Seahorse is "Passwords and Keys" app from GNOME. It used to be a
      # part of pkgs.gnome, but now it's a top-level application.
      pkgs.seahorse
    ];
  };
}
