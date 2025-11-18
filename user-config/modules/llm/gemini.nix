{ pkgs
, lib
, config
, ...}:

{
  options = {
    llm.gemini.enable = lib.mkEnableOption "Enable Gemini setup.";
  };

  config = lib.mkIf config.llm.gemini.enable {
    home.packages = [
      pkgs.gemini-cli
    ];
  };
}
