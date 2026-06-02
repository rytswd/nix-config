# ClamAV -- not imported by the security bundle's default.nix. Import this
# leaf directly from a host config when I want it.
{
  services.clamav = {
    scanner.enable = true;
    daemon.enable = true;
    updater.enable = true;
  };
}
