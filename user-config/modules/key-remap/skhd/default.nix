{ pkgs
, lib
, config
, ...}:

# The assumption here is that, it is unlikely to have other key remapping
# options installed at the same time.
{
  xdg.configFile = {
    "skhd/skhdrc".source = ./skhdrc;
  };
}
