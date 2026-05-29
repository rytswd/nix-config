# GDM — not imported by the login-manager bundle's default.nix. Import this
# leaf directly from a host config when I want GDM instead of sddm.
{
  services.xserver.displayManager.gdm.enable = true;
}
