{
  # HACK: I shouldn't need this, but making sure any keyboard input device
  # is considered for the dwt (disable while typing) functionality from
  # libinput.
  environment.etc."libinput/local-overrides.quirks".text =
    ''
      [xremap]
      MatchUdevType=keyboard
      AttrKeyboardIntegration=internal
    '';
}
