{ pkgs, ... }:
# PipeWire as the audio + screen-cast stack, replacing PulseAudio.
#
# History note: this module used to also touch `sound.enable`. That option
# was removed entirely from NixOS in https://github.com/NixOS/nixpkgs/pull/326262
# ("kill sound.enable and friends with fire", merged Jul 2024). A renaming
# proposal (#319839) was superseded by that removal -- there is no
# `hardware.alsa.enable` to set instead; ALSA is just always available and
# PipeWire's `alsa.enable` below plugs into it.
{
  # PipeWire's `pulse.enable` asserts `services.pulseaudio.enable = false`
  # upstream, but being explicit here makes the intent obvious.
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Realtime scheduling for audio threads -- recommended by PipeWire upstream
  # and the NixOS pipewire docs.
  security.rtkit.enable = true;

  # PulseAudio-compatible volume / per-app routing GUI.
  environment.systemPackages = [
    pkgs.pavucontrol
  ];
}
