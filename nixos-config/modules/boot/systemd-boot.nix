# systemd-boot boot loader. Not imported by the core boot bundle's default.nix
# -- bootloaders are mutually exclusive, so hosts import the one they want.
{
  # The systemd-boot seems to be the standard, but I didn't like how it
  # looked (and the screen resolution was sort of bugging out).
  # Ref: https://www.freedesktop.org/software/systemd/man/latest/loader.conf.html
  boot.loader.systemd-boot = {
    enable = true;

    editor = true;
    consoleMode = "auto";
  };
}
