{ pkgs
, lib
, config
, ...}:

# Because this module is specific to laptop, the import of this module would
# directly enable the laptop related configuration.

{
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';
}
