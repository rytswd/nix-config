{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.markdown.enable = lib.mkEnableOption "Enable Markdown related tools.";
  };

  config = lib.mkIf config.programming.markdown.enable {
    home.packages = [
      pkgs.pandoc

      # pkgs.python311.pkgs.grip # https://github.com/joeyespo/grip
      pkgs.python-grip # Overlay in place for the above to get the latest master.
    ];
  };
}
