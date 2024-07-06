{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.shell.enable = lib.mkEnableOption "Enable shell.";
  };

  config = lib.mkIf config.core.shell.enable {
    # These shell settings are global configurations, meaning they would work on
    # files under /etc/ (and they would be stored in /etc/static/).
    #
    # NOTE: Upon the initial installation, the files such as /etc/bashrc, etc.
    # may need to be moved manually so that Nix can create the new files.

    # programs.bash.enable = true; # NOTE: This has no effect and needs to be taken out.
    programs.fish.enable = true;
    programs.zsh.enable = true;
  };
}
