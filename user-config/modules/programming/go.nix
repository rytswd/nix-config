{ pkgs, config, ... }:
{
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
    env = {
      GOPATH = "${config.home.homeDirectory}/Coding/go";
      GOBIN = "${config.home.homeDirectory}/Coding/go/bin";
      GOPRIVATE = [
        "github.com/rytswd"
      ];
    };
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/Coding/go/bin"
  ];
}
