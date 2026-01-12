{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.claude.enable = lib.mkEnableOption "Enable Claude setup.";
  };

  config = lib.mkIf config.llm.claude.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.system}; [
      claude-code
      claudebox
    ];
  };
}
