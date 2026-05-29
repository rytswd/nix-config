{ pkgs, inputs, ... }:
{
  home.packages = [
    pkgs.nix-prefetch-github
    pkgs.nix-output-monitor
    pkgs.nvd
    pkgs.nixd # Language Server
    pkgs.nixpkgs-review # PR review utility
    pkgs.alejandra # Formatting
    pkgs.nixfmt # Formatting
  ]
  ++ [
    # Because of Darwin support provided by a separate flake, this ensures
    # there is no conflicting package on macOS. NixOS technically doesn't need
    # this setup if nh is made available on NixOS level.
    (if pkgs.stdenv.isDarwin then { } else pkgs.nh)
  ];
  home.shellAliases = {
    flakeinit = "nix flake init -t \"github:rytswd/nix-direnv-template\" --refresh";
  };
  # Pin $NIX_PATH's `<nixpkgs>` to this flake's `nixpkgs-unstable` input so
  # legacy / non-flake lookups resolve to a known revision:
  #   - Nixd (language server) reads $NIX_PATH for option completion and
  #     `with pkgs;` understanding.
  #   - `nix-shell -p …`, `nix-env`, `nix repl '<nixpkgs>'`, and any code
  #     doing `import <nixpkgs> {}`.
  #
  # Does NOT affect flake-style commands (`nix shell nixpkgs#…`,
  # `nix run nixpkgs#…`, `nix build nixpkgs#…`) — those go through the
  # flake registry. That side is pinned to the same `nixpkgs-unstable`
  # input by `nixos-config/modules/nix-base.nix`
  # (`nix.registry.nixpkgs.flake`), so the two stay aligned.
  #
  # TODO: also add Nixd-specific configuration on top of this.
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
}
