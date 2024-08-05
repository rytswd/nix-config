{ pkgs
, lib
, config
, ...}:

{
  options = {
    input.trackpad.enable = lib.mkEnableOption "Enable trackpad settings.";
  };

  config = lib.mkIf config.input.trackpad.enable {
    # Disable the touchpad while typing.
    # NOTE: This works by itself, but other key remapping solutions like xremap
    # would change the behaviour and may not have any effect because of that.
    services.libinput.touchpad.disableWhileTyping = true;
  };
}
