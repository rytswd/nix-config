{
  imports = [
    ./gnome.nix
    ./cosmic.nix
    # NOTE: ./dconf.nix is intentionally NOT imported here — dconf overrides
    # are host-specific. Import the leaf directly from a host config.
  ];
}
