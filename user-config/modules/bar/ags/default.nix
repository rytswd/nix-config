{ inputs, ... }:
# AGS (Aylur's GTK Shell) — not imported by the bar bundle's default.nix.
# Import this leaf directly from a host config if you actually want it.
{
  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./config;
  };
}
