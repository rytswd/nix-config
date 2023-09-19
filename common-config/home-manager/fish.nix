{ pkgs, ... }:

{
  enable = true;
  # Add fish specific aliases
  shellAliases =
    (import ./aliases-ls.nix { withEza = true; }) //
    {
      # Any aliases specific for fish can be defined here.
    };
  shellAbbrs = {
    tm = "tmux new-session -A -D -s main";
    ec = "emacsclient";
    flake = "nix flake";
  };
}
