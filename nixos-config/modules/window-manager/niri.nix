{ pkgs
, lib
, config
, niri
, ...}:

{
  options = {
    window-manager.niri.enable = lib.mkEnableOption "Enable Niri window manager.";
  };

  config = lib.mkIf config.window-manager.niri.enable {
    environment.systemPackages = [
      pkgs.niri-unstable
    ];

    # NOTE: This can only be enabled once built with this stanza commented out.
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
  };
}
