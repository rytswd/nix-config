{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.codex.enable = lib.mkEnableOption "Enable Codex setup.";
  };

  config = lib.mkIf config.llm.codex.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      codex
      code
    ];
  };
}
