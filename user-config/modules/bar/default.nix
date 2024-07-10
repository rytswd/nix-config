{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./waybar.nix
    ./ags.nix
    # TODO: Move sketchybar setup here
    # ./sketchybar.nix
  ];

  # NOTE: I'm setting no default here, so importing this bar module does not
  # enable any bar by default. There could be an OS based check I could add
  # to the mix, but for now, this is good enough.
  # bar.waybar.enable = lib.mkDefault true;
}
