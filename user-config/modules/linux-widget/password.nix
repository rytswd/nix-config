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
      # NOTE: When GNOME is enabled for the NixOS as a whole, I can make use of
      # the system wide installation. But I'm just making sure that the user
      # config can make use of Seahorse (aka Passwords and Keys).
      pkgs.gnome.seahorse
    ];
  };
}
