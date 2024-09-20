{ pkgs
, lib
, config
, ...}:

{
  options = {
    devices.keyboard.enable = lib.mkEnableOption "Enable keyboard related adjustment.";
  };

  config = lib.mkIf config.devices.keyboard.enable {
    # HACK: I shouldn't need this, but making sure any keyboard input device
    # is considered for the dwt (disable while typing) functionality from
    # libinput.
    environment.etc."libinput/local-overrides.quirks" =
      ''
        [xremap]
        MatchUdevType=keyboard
        AttrKeyboardIntegration=interna
      '';
  };
}
