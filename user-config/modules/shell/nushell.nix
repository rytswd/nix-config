{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.nushell.enable = lib.mkEnableOption "Enable Nushell.";
  };

  config = lib.mkIf config.shell.nushell.enable {
    programs.nushell = {
      enable = true;
      shellAliases = (import ./aliases-ls.nix { withEza = true; }) //
        {
          # Any aliases specific for fish can be defined here.
        };
   };
  };
}
