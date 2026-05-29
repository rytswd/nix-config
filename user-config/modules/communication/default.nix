{
  imports = [
    ./email.nix
    # NOTE: ./slack.nix, ./signal.nix, ./discord.nix, ./telegram.nix,
    # ./zoom.nix are intentionally NOT imported here — opt-in per host.
  ];
}
