# Ref: https://github.com/mitchellh/nixos-config/blob/main/hardware/vm-aarch64.nix
{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnumake
    killall
    rxvt_unicode
    xclip
    firefox

    # For hypervisors that support auto-resizing, this script forces it.
    # I've noticed not everyone listens to the udev events so this is a hack.
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  # ] ++ lib.optionals (currentSystemName == "vm-aarch64") [
    # This is needed for the vmware user tools clipboard to work.
    # You can test if you don't need this by deleting this and seeing
    # if the clipboard sill works.
    gtkmm3

    # VMware on M1 doesn't support automatic resizing yet and on
    # my big monitor it doesn't detect the resolution either so we just
    # manualy create the resolution and switch to it with this script.
    # This script could be better but its hopefully temporary so just force it.
    (writeShellScriptBin "xrandr-6k" ''
      xrandr --newmode "6016x3384_60.00"  1768.50  6016 6544 7216 8416  3384 3387 3392 3503 -hsync +vsync
      xrandr --addmode Virtual-1 6016x3384_60.00
      xrandr -s 6016x3384_60.00
    '')
    (writeShellScriptBin "xrandr-mbp" ''
      xrandr -s 2880x1800
    '')
  ];
}
