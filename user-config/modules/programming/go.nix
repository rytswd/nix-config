{ pkgs, config, self, ... }:
let
  # Pull a newer Go than nixpkgs currently ships, applied LOCALLY rather than
  # as a global overlay -- so only this home-manager module rebuilds Go and the
  # stable system closure is left untouched. The override (version, bootstrap,
  # and patch handling) lives in ../../../overlays/go.nix; we apply it here
  # against this module's (unstable) pkgs.
  go-latest = ((import "${self}/overlays/go.nix") pkgs pkgs).go;

  # Derive GOPATH from `local.codeRoot` rather than hard-coding
  # `$HOME/Coding/go`, so it follows the per-host checkout root
  # (`$HOME/Coding` on personal machines, `$HOME/src` on coder
  # workspaces -- see user-config/modules/lib/paths.nix). GOBIN and the
  # PATH entry below stay in lockstep with this single value.
  goPath = "${config.local.codeRoot}/go";
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
      GOPATH = goPath;
      GOBIN = "${goPath}/bin";
      GOPRIVATE = [
        "github.com/rytswd"
      ];
    };
  };
  home.sessionPath = [
    "${goPath}/bin"
  ];
}
