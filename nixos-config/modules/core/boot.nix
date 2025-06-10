{ pkgs
  , lib
  , config
  , ...}:

{
  options = {
    core.boot.enable = lib.mkEnableOption "Enable boot settings.";
  };

  config = lib.mkIf config.core.boot.enable {
    boot = {
      loader = {
        # Only one can be enabled at a time. Others that are not enabled are
        # there only for reference.

        limine = {
          # Ref: https://github.com/limine-bootloader/limine/blob/v9.x/CONFIG.md
          enable = true;

          style.wallpapers = [ ./hasliberg.jpg ];
        };

        grub = {
          # NOTE: I used to have GRUB config at one point, but found it too much
          # complication for my own needs.
          enable = false;

          efiSupport = true;
          device = "nodev";
          fsIdentifier = "label";
          # efiInstallAsRemovable = true;
          gfxmodeEfi = "1920x1200";
          font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
          fontSize = 36;
        };

        systemd-boot = {
          # The systemd-boot seems to be the standard, but I didn't like how it
          # looked (and the screen resolution was sort of bugging out).
          # Ref: https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html
          enable = false;

          editor = true;
          consoleMode = "auto";
        };



        efi.canTouchEfiVariables = true;
      };

      # Be careful updating this.
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
