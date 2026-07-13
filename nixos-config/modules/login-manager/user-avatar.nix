{
  config,
  lib,
  ...
}:
# Publish a user's avatar image to /var/lib/AccountsService/icons/<user> so the
# login greeter shows it. The SDDM taketomi theme renders that path directly
# (login-manager/sddm/taketomi-theme/Components/Avatar.qml), and AccountsService
# aware greeters read it too. Without it the greeter falls back to an
# initial-letter tile.
#
# A *copy* is published rather than a symlink to ~/.face: the greeter runs as
# the unprivileged `sddm` user and cannot traverse a 0700 home, so it needs a
# root-owned file it can read. systemd-tmpfiles runs early at boot (well before
# any display manager), so a one-line copy rule is all this needs.
#
# Not imported by ./default.nix -- this is a host-specific leaf (only machines
# with a graphical greeter want it). Import it directly and set
# `loginManager.avatar.user`, the same way ../devices/yubikey.nix is wired.
let
  cfg = config.loginManager.avatar;
  source = if cfg.source != null then cfg.source else "/home/${cfg.user}/.face";
in
{
  options.loginManager.avatar = {
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "ryota";
      description = ''
        User whose avatar is published to `/var/lib/AccountsService/icons/<user>`
        for the login greeter. `null` (the default) disables it entirely.
      '';
    };

    source = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/ryota/.face";
      description = ''
        Image file published as the avatar. When `null`, defaults to the
        user's `~/.face`. A missing file is ignored (the `C-` rule tolerates
        errors), so this stays a no-op on a fresh install before it exists.
      '';
    };
  };

  config = lib.mkIf (cfg.user != null) {
    # `C-` copies `source` -> the icons path only when the target is missing (and
    # tolerates a missing source). That also re-copies for free once ephemeral
    # root wipes /var/lib each boot (see nix-impermanence.nix) -- no persistence
    # entry needed. To pick up a changed image before then:
    # `sudo systemd-tmpfiles --create` (or delete the target and rebuild).
    systemd.tmpfiles.rules = [
      "C- /var/lib/AccountsService/icons/${cfg.user} 0644 root root - ${source}"
    ];
  };
}
