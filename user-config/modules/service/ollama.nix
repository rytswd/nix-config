{ pkgs
, lib
, config
, ...}:

# Ref: https://ollama.dev/

{
  options = {
    service.ollama.enable = lib.mkEnableOption "Enable Ollama related tooling.";
  };

  config = lib.mkIf config.service.ollama.enable {
    home.packages = [
      pkgs.ollama
    ];
    # TODO: Handle ollama server process
  };
}
