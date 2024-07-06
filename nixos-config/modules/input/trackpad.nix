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
    # TODO: Check if this is actually working, and move this somewhere more sensible
    services.libinput.touchpad.disableWhileTyping = true;
  };
}
