# uinput access for xremap. The YubiKey hotplug rule that used to also live
# here was moved to nixos-config/modules/devices/yubikey.nix where it can
# take the target user as an option (`devices.yubikey.user`) instead of
# hardcoding it.
#
# Ref: https://github.com/xremap/xremap/blob/master/doc/running_without_sudo.md
{
  hardware.uinput.enable = true;
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", TAG+="uaccess"
  '';
}
