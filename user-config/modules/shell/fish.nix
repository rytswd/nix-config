{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.fish.enable = lib.mkEnableOption "Enable Fish.";
  };

  config = lib.mkIf config.shell.fish.enable {
    programs.fish = {
      enable = true;
      shellAliases = (import ./aliases-ls.nix { withEza = true; }) //
        {
          # Any aliases specific for fish can be defined here.
        };
      shellAbbrs = {
        tm = "tmux new-session -A -D -s main";
        ec = "emacsclient -n";
        flake = "nix flake";
      };
    };
  };
}
