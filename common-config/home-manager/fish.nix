{ pkgs, ... }:

{
  enable = true;
  # Add fish specific aliases
  shellAliases =
    (import ./aliases-ls.nix { withExa = true; }) //
    {
      # Any aliases specific for fish can be defined here.
    };
  shellAbbrs = {
    tm = "tmux new-session -A -D -s main";
    ec = "emacsclient";
  };
}
