{ pkgs
, lib
, config
, ...}:

{
  options = {
    llm.claude.enable = lib.mkEnableOption "Enable Claude setup.";
  };

  config = lib.mkIf config.llm.claude.enable {
    home.packages = [
      pkgs.claude-code
    ];
  };
}
