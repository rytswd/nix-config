{ pkgs
, lib
, config
, ...}:

{
  options = {
    llm.opencode.enable = lib.mkEnableOption "Enable OpenCode setup.";
  };

  config = lib.mkIf config.llm.opencode.enable {
    programs.opencode = {
      enable = true;
    };
  };
}
