{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.user-management.enable = lib.mkEnableOption "Enable basic user management settings.";
  };

  config = lib.mkIf config.core.user-management.enable {
    # Ensure password can be changed with `passwd`.
    users.mutableUsers = false;

    # Don't require password for sudo
    security.sudo.wheelNeedsPassword = false;
  };
}
