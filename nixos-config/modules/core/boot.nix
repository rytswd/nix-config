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
        # grub = {
        #   enable = true;
        #   efiSupport = true;
        #   device = "nodev";
        #   fsIdentifier = "label";
        #   efiInstallAsRemovable = true;
        #   gfxmodeEfi = "2880x1800";
        #   font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
        #   fontSize = 24;
        #   backgroundColor = "#7EBAE4";
        # };

        systemd-boot.enable = true;
        systemd-boot.consoleMode = "auto";
        efi.canTouchEfiVariables = true;
      };

      # Be careful updating this.
      kernelPackages = pkgs.linuxPackages_latest;
    };
  };
}
