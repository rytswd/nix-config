{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    core.boot.grub.enable = lib.mkEnableOption "Enable systemd-boot boot loader.";
  };

  config = lib.mkIf config.core.boot.grub.enable {
    boot.loader = {
      # Only one can be enabled at a time. Others that are not enabled are
      # there only for reference.
      systemd-boot = {
        # The systemd-boot seems to be the standard, but I didn't like how it
        # looked (and the screen resolution was sort of bugging out).
        # Ref: https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html
        enable = true;

        editor = true;
        consoleMode = "auto";
      };
    };
  };
}
