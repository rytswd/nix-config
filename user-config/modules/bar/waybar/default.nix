{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.waybar.enable = lib.mkEnableOption "Enable Waybar.";
  };

  config = lib.mkIf config.bar.waybar.enable {
    programs.waybar = {
      enable = true;

      # TODO: I may need to reconsider this approach, and create a separate /
      # dedicated systemd setup as I want to have both top and bottom bars.
      systemd.enable = true;

      # NOTE: I'm not using the Nix based definitions as it was easier to test
      # using direct jsonc and css inputs.
    };
    xdg.configFile = {
      # NOTE: Creating top configs only for now.
      "waybar/config".source = ./config_top.jsonc;
      "waybar/style.css".source = ./style_top.css;
    };
  };
}
