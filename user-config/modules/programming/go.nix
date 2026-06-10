{ pkgs, config, self, ... }:
let
  # Pull a newer Go than nixpkgs currently ships, applied LOCALLY rather than
  # as a global overlay -- so only this home-manager module rebuilds Go and the
  # stable system closure is left untouched. The override (version, bootstrap,
  # and patch handling) lives in ../../../overlays/go.nix; we apply it here
  # against this module's (unstable) pkgs.
  go-latest = ((import "${self}/overlays/go.nix") pkgs pkgs).go;
in
{
  home.packages = [
    # Because Vim plugin govim requires Go binary to be available, I'm
    # installing it globally rather than by using direnv.
    go-latest
    pkgs.ko
    pkgs.gopls
    pkgs.templ
    pkgs.delve
  ];
  programs.go = {
    enable = true;
    # Keep programs.go in sync with the package installed above.
    package = go-latest;
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
