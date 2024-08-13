{ pkgs
, lib
, config
, ...}:

{
  options = {
    screenshot.grim.enable = lib.mkEnableOption "Enable Grim.";
  };

  config = lib.mkIf config.screenshot.grim.enable {
    home.packages = [
      pkgs.grim     # https://sr.ht/~emersion/grim/
      pkgs.slurp    # https://github.com/emersion/slurp
    ];
  };
}
