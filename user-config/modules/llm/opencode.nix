{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.opencode.enable = lib.mkEnableOption "Enable OpenCode setup.";
  };

  config = lib.mkIf config.llm.opencode.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.system}; [
      opencode
    ];
  };
}
