{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.bash.enable = lib.mkEnableOption "Enable Bash.";
  };

  config = lib.mkIf config.shell.bash.enable {
    programs.bash = {
      enable = true;
      shellAliases = (import ./aliases-ls.nix { withEza = true; }) //
        (if pkgs.stdenv.isDarwin
         then {
           # Any aliases specific for bash can be defined here.

           # Temporary alias for setting up Homebrew PATH for the current session.
           brewsup = "export PATH=\"/opt/homebrew/bin:/opt/homebrew/sbin:${PATH+:$PATH}\"";
         }
         else {
           # Any aliases specific for bash can be defined here.
         });
    };
  };
}
