{ pkgs
, lib
, config
, inputs
, ...}:

# Because Xremap flake module needs to be loaded up for the setting here, I'm
# making an isolated module within key-remap. This assumes that the import of
# this module would directly enable the Xremap without any extra option.
#
# The assumption here is that, it is unlikely to have other key remapping
# options installed at the same time.

{
  imports = [ inputs.xremap.homeManagerModules.default ];

  services.xremap = {
    enable = true;
    withWlroots = true;
    # Ensures I do not have to restart the service when definition changes
    watch = true;
    # The list of devices can be seen in xremap initialisation logs:
    #
    #     journalctl --user -xeu xremap
    #
    deviceNames = [
      "Asus Keyboard"
      "Naya B.V. Create Left Keyboard"
      "Naya Create Keyboard"
    ];
    yamlConfig = (builtins.readFile ./xremap.yaml);
  };
}
