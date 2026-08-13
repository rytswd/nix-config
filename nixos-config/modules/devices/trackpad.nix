{
  services.libinput.touchpad = {
    # TODO: I was hpoing this would work for screenshot dragging, but not
    # really. I need to sort this out.
    tappingDragLock = true;
    # Disable the touchpad while typing.
    #
    # NOTE: this option only ever reaches an X11 session -- the NixOS module
    # writes it into /etc/X11/xorg.conf.d/40-libinput.conf and nothing else
    # reads that file. Under niri (or any Wayland compositor) the compositor
    # owns libinput configuration, so dwt has to be set there instead; see
    # `input.touchpad.dwt` in the niri config. Kept here for the X11/tty
    # fallback path rather than deleted, since it is harmless and correct
    # for the sessions it does apply to.
    disableWhileTyping = true;
  };

  # Make libinput expose disable-while-typing on the Z13's detachable folio.
  #
  # WHY: libinput only offers dwt on *internal* touchpads, and it decides
  # internal vs. external from the udev property ID_INPUT_TOUCHPAD_INTEGRATION.
  # The folio attaches over the pogo connector on the bottom edge, but that
  # connector is wired as an internal USB bus -- the kernel enumerates the
  # touchpad through usbhid as 0b05:1a30. udev's "USB implies external"
  # heuristic therefore tags it `external`, libinput reports
  # `Disable-w-typing: n/a`, and *every* dwt setting silently does nothing:
  # niri's `dwt`, and the X11 option above alike. The touchpad is physically
  # integrated, so the heuristic is simply wrong here and we override it.
  #
  # WHY NOT a libinput quirk: libinput 1.31.3 ships no AttrTouchpadIntegration
  # attribute -- only AttrKeyboardIntegration and AttrPointingStickIntegration
  # -- so touchpad integration cannot be expressed in
  # /etc/libinput/local-overrides.quirks the way the xremap keyboard tagging in
  # keyboard.nix is. The udev property is the only lever.
  #
  # Matching on the USB ID keeps this inert on every other host that imports
  # this module; the rule simply never fires there.
  #
  # Verify with:
  #   libinput list-devices | grep -A16 'GZ302EA-Keyboard Touchpad'
  # expecting `Disable-w-typing: enabled` rather than `n/a`. The compositor
  # reads the property when it opens the device, so niri needs a restart (or
  # the folio re-attached) after this lands.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="input", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_USB_VENDOR_ID}=="0b05", ENV{ID_USB_MODEL_ID}=="1a30", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"
  '';
}
