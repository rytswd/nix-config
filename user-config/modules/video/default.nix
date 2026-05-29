{
  imports = [
    ./obs.nix
    ./wf-recorder.nix
    # NOTE: ./davinci.nix is intentionally NOT imported here — opt-in per host.
  ];
}
