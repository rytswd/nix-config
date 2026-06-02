{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    # 32-bit GL libs are useful for Steam / Wine on x86_64 desktops; the
    # option is rejected on aarch64 (no multilib).
    enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
    # extraPackages = [ pkgs.virglrenderer ];
  };

  # NOTE: Noctalia requires this as dependency. Because of udev rules setup,
  # this needs to be at NixOS level, not user level.
  environment.systemPackages = [ pkgs.brightnessctl ];
}
