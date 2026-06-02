{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # extraPackages = [ pkgs.virglrenderer ];
  };

  # NOTE: Noctalia requires this as dependency. Because of udev rules setup,
  # this needs to be at NixOS level, not user level.
  environment.systemPackages = [ pkgs.brightnessctl ];
}
