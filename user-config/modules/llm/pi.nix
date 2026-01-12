{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    llm.pi.enable = lib.mkEnableOption "Enable Pi agent setup.";
  };

  config = lib.mkIf config.llm.pi.enable {
    home.packages = with inputs.llm-agents.packages.${pkgs.system}; [
      pi
    ];
  };
}
