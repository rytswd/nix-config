{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.tmp.enable = lib.mkEnableOption "Enable /tmp handling.";
  };

  config = lib.mkIf config.core.tmp.enable {
    boot.tmp.cleanOnBoot = true;
    # I'm not using the tmpfs as it can fail large Nix builds.
    # boot.tmp.useTmpfs = true;
  };
}
