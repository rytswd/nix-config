{ pkgs, ... }:
{
  hardware.uinput.enable = true;
  services.udev = {
    # NOTE: Xremap requires the following:
    # https://github.com/xremap/xremap/blob/master/doc/running_without_sudo.md
    extraRules = ''
      KERNEL=="uinput", GROUP="input", TAG+="uaccess"
      ACTION=="add|remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", \
          RUN+="${pkgs.systemd}/bin/machinectl shell --uid=ryota .host /bin/sh -c 'systemctl --user start yk-git-update.service || true'"
    '';
  };
}
