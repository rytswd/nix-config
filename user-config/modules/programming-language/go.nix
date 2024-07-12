{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.go.enable = lib.mkEnableOption "Enable Go development related tools.";
  };

  config = lib.mkIf config.programming-language.go.enable {
    home.packages = [
      # Because Vim plugin govim requires Go binary to be available, I'm
      # installing it globally rather than by using direnv.
      pkgs.go
      pkgs.ko
      pkgs.gopls
      pkgs.templ
    ];
  };
}
