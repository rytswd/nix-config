# nix-darwin module flake outputs.
#
# Lists what gets exposed as `<flake>.darwinModules.<name>`. Adding a new
# module file does NOT automatically expose it -- add a line below.
# Commenting / removing a line hides the module from downstream consumers.
#
# Paths are resolved relative to this file.
{
  appearance = ./appearance;
}
