{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.zed.enable = lib.mkEnableOption "Enable Zed.";
  };

  config = lib.mkIf config.editor.zed.enable {
    programs.zed-editor = {
      enable = true;
    };
  };
}
