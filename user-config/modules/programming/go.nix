{ pkgs, config, self, ... }:
let
  # Pull a newer Go than nixpkgs currently ships, applied LOCALLY rather than
  # as a global overlay -- so only this home-manager module rebuilds Go and the
  # stable system closure is left untouched. The override (version, bootstrap,
  # and patch handling) lives in ../../../overlays/go.nix; we apply it here
  # against this module's (unstable) pkgs.
  go-latest = ((import "${self}/overlays/go.nix") pkgs pkgs).go;

  # GOPATH follows `local.goRoot` (a `local.*` option alongside codeRoot /
  # binRoot) rather than being derived in this module, so per-host
  # profiles can move the whole Go tree without touching it -- coder
  # workspaces point it at their persistent volume so `go install`
  # artifacts survive a workspace recycle, while the default
  # (`<codeRoot>/go`, i.e. `$HOME/Coding/go` on personal machines) keeps
  # existing hosts exactly where they were. See
  # user-config/modules/lib/paths.nix and user-config/ryota/coder.nix.
  goPath = config.local.goRoot;
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
      # GOBIN is plain `<GOPATH>/bin` -- exactly what Go would infer if it
      # were unset. Exported anyway so the `go install` target and the
      # sessionPath entry below are visibly tied to the same single value,
      # and so it keeps working should GOPATH ever grow extra entries
      # (Go refuses to infer GOBIN from a multi-entry GOPATH).
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
