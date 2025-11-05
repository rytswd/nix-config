{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./waybar
    # ./ags
    ./sketchybar
  ];

  # NOTE: I'm setting no default here, so importing this bar module does not
  # enable any bar by default. There could be an OS based check I could add
  # to the mix, but for now, this is good enough.
}
