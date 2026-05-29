{ pkgs, inputs, ... }:
{
  home.packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    workmux
  ];
  xdg.configFile = {
    "workmux/config.yaml".source = ./workmux.yaml;
  };
}
