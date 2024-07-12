{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.helix.enable = lib.mkEnableOption "Enable Helix.";
  };

  config = lib.mkIf config.editor.helix.enable {
    programs.helix = {
      enable = true;
      # Because Helix uses TOML for its configuration, I configure them
      # separately.
    };
  };
}
