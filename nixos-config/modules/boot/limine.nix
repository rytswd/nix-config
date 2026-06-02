# Limine boot loader. Not imported by the core boot bundle's default.nix --
# bootloaders are mutually exclusive, so hosts import the one they want.
{
  boot.loader.limine = {
    enable = true;
    style.wallpapers = [ ./hasliberg.jpg ];
  };
}
