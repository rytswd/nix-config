{ pkgs
, lib
, config
, ...}:

{
  options = {
    input.trackpad.enable = lib.mkEnableOption "Enable trackpad settings.";
  };

  config = lib.mkIf config.input.trackpad.enable {
    services.libinput.touchpad = {
      # TODO: I was hpoing this would work for screenshot dragging, but not
      # really. I need to sort this out.
      tappingDragLock = true;
      # Disable the touchpad while typing.
      # NOTE: This works by itself, but other key remapping solutions like
      # xremap would change the behaviour and may not have any effect because
      # of that.
      disableWhileTyping = true;
    };
  };
}
