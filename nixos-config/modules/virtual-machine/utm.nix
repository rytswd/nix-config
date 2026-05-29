# UTM-specific guest tweaks. NOT imported by the virtual-machine bundle's
# default.nix — import this leaf directly when the host hypervisor is UTM.
#
# Ref: https://docs.getutm.app/guest-support/linux/
{
  # SPICE WebDAV channel — exposes the UTM host's "Shared Directory" as a
  # WebDAV mount inside the guest (e.g. via `gio mount sftp://...` from a
  # file manager, or by reading `/run/user/$UID/gvfs/dav:host=...`).
  #
  # NOTE: the previous file-sharing.nix had a large commented-out davfs2 +
  # autofs block that tried to mount this as a regular filesystem path. It
  # didn't work reliably (the URL/port depended on the UTM build, and the
  # mount races the user session). For now: use `spice-webdavd` + a file
  # manager that speaks GVfs. Add per-host mount automation in the host
  # config if/when needed, not in this shared module.
  services.spice-webdavd.enable = true;
}
