{ pkgs
, lib
, config
, ...}:

# Because this module is specific to Asus machine, the import of this module would
# directly enable the Asus related configuration.

{
  # NOTE: The config taken from:
  # https://asus-linux.org/guides/nixos/
  services.supergfxd.enable = true;
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
}
