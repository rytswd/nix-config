{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    core.boot.limine.enable = lib.mkEnableOption "Enable limine boot loader.";
  };

  config = lib.mkIf config.core.boot.limine.enable {
    boot.loader = {
      # Only one can be enabled at a time. Others that are not enabled are
      # there only for reference.

      limine = {
        enable = true;

        style.wallpapers = [ ./hasliberg.jpg ];
      };
    };
  };
}
