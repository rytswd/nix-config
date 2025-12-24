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
        # Limine was my preference in terms of its visual appeal, but it cannot
        # work with LUKS as of writing.
        # https://codeberg.org/Limine/Limine/src/branch/v10.x/FAQ.md
        # Ref: https://github.com/limine-bootloader/limine/blob/v9.x/CONFIG.md
        enable = true;

        style.wallpapers = [ ./hasliberg.jpg ];
      };
    };
  };
}
