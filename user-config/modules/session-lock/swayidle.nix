{ pkgs
, lib
, config
, ...}:

{
  options = {
    session-lock.swayidle.enable = lib.mkEnableOption "Enable swayidle.";
  };

  config = lib.mkIf config.session-lock.swayidle.enable {
    services.swayidle = {
      enable = true;
      # systemdTarget = "sway-session.target";
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
      ];
      timeouts = [
        # 15 min
        { timeout = (60 * 15); command = "${pkgs.swaylock-effects}/bin/swaylock"; }
        # 30 min
        { timeout = (60 * 30); command = "${pkgs.systemd}/bin/systemctl suspend"; }
      ];
    };

    # Force systemd to not care about the WAYLAND_DISPLAY env variable.
    systemd.user.services.swayidle = {
      Unit.ConditionEnvironment = lib.mkForce ""; # Updated.
    };
  };
}
