{ pkgs
, lib
, config
, ...}:

{
  options = {
    media.pipewire.enable = lib.mkEnableOption "Enable pipewire.";
  };

  config = lib.mkIf config.media.pipewire.enable {
    # Ref: https://github.com/NixOS/nixpkgs/issues/319809
    # Removing the sound setup which seems to be causing rebuild issue. Since
    # PipeWire seems to have a better audio and screen support in general, disable
    # the below clearly (as sound.enable is meant to be ALSA).
    # For PipeWire, this needs to be explicitly set to false.
    hardware.pulseaudio.enable = false;
    # "sound.enable" is analogous to hardware.alsa (PR
    # https://github.com/NixOS/nixpkgs/pull/319839 pending as of writing), and
    # because PulseAudio being disabled updates this field, commenting it out. (It
    # is purely no-op either way.)
    # sound.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # Ref: https://www.reddit.com/r/linuxquestions/comments/10chul6/what_the_hell_is_a_pipewire_alsa_pulseaudio_and/

    # Making pavucontrol GUI available by default.
    environment.systemPackages = [
      pkgs.pavucontrol
    ];
  };
}
