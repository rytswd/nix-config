{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.go.enable = lib.mkEnableOption "Enable Go development related tools.";
  };

  config = lib.mkIf config.programming.go.enable {
    home.packages = [
      # Because Vim plugin govim requires Go binary to be available, I'm
      # installing it globally rather than by using direnv.
      pkgs.go
      pkgs.ko
      pkgs.gopls
      pkgs.templ
      pkgs.delve
    ];
    programs.go = {
      enable = true;
      goPath = "Coding/go";
      goBin = "Coding/go/bin";
      goPrivate = [ "github.com/rytswd" "github.com/upsidr" ];
    };
  };
}
