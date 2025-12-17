{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.gemini.enable = lib.mkEnableOption "Enable Gemini setup.";
  };

  config = lib.mkIf config.llm.gemini.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.system}; [
      gemini-cli
    ];
  };
}
