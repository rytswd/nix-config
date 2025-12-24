{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    core.boot.grub.enable = lib.mkEnableOption "Enable Grub boot loader.";
  };

  config = lib.mkIf config.core.boot.grub.enable {
    boot.loader = {
      # Only one can be enabled at a time. Others that are not enabled are
      # there only for reference.

      grub = {
        # NOTE: I used to have GRUB config at one point, but found it too much
        # complication for my own needs.
        enable = true;

        efiSupport = true;
        device = "nodev";
        fsIdentifier = "label";
        # efiInstallAsRemovable = true;
        gfxmodeEfi = "1920x1200";
        font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
        fontSize = 36;
      };
    };
  };
}
