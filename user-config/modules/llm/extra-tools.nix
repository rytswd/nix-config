{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.extra-tools.enable = lib.mkEnableOption "Enable extra tools for LLM setup.";
  };

  config = lib.mkIf config.llm.extra-tools.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      workmux
    ];
  };
}
