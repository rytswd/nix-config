{ pkgs, ... }:
# GRUB boot loader. Not imported by the core boot bundle's default.nix —
# bootloaders are mutually exclusive, so hosts import the one they want.
{
  # NOTE: I used to have GRUB config at one point, but found it too much
  # complication for my own needs.
  boot.loader.grub = {
    enable = true;

    efiSupport = true;
    device = "nodev";
    fsIdentifier = "label";
    # efiInstallAsRemovable = true;
    gfxmodeEfi = "1920x1200";
    font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
    fontSize = 36;
  };
}
