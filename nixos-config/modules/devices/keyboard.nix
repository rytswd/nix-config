{
  # HACK: I shouldn't need this, but making sure any keyboard input device
  # is considered for the dwt (disable while typing) functionality from
  # libinput.
  environment.etc."libinput/local-overrides.quirks".text =
    ''
      # Only the xremap virtual keyboard -- not every keyboard on the system.
      # Tagging all keyboards as `internal` caused libinput to suspend the
      # Bluetooth keyboard when SW_TABLET_MODE fires on Z13 keyboard detach.
      [xremap virtual keyboard]
      MatchName=xremap
      MatchUdevType=keyboard
      AttrKeyboardIntegration=internal
    '';

  # System-wide XKB keyboard layouts. The user session is driven by
  # home-manager (Wayland compositor / xremap configuration), so these
  # settings exist primarily so the display manager (SDDM/GDM) and any
  # tty/X session see the same layouts before home-manager kicks in.
  #
  # Lives under `services.xserver.*` for historical reasons; the settings
  # are written to /etc/X11/xkb regardless of whether xserver is enabled,
  # so they take effect under Wayland sessions too.
  services.xserver.xkb = {
    layout = "us,us,jp";
    variant = "dvorak,,";
    options = "ctrl:nocaps"; # Configure Caps Lock to be Ctrl.
  };
}
