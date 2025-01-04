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
        grub.enable = false;
        # NOTE: I used to have GRUB config at one point, but found it too much
        # complication for my own needs.
        # grub = {
        #   enable = true;
        #   efiSupport = true;
        #   device = "nodev";
        #   fsIdentifier = "label";
        #   # efiInstallAsRemovable = true;
        #   gfxmodeEfi = "1920x1200";
        #   font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
        #   fontSize = 36;
        # };

        systemd-boot.enable = true;
        systemd-boot.editor = true;
        systemd-boot.consoleMode = "auto";
        efi.canTouchEfiVariables = true;
      };

      # Be careful updating this.
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
