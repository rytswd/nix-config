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
        { event = "lock"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
        { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock"; }
        # { event = "after-resume"; command = "${pkgs.sway}/bin/swaymsg \"output * toggle\""; }
      ];
      timeouts = [
        # 15 min
        { timeout = (60 * 15); command = "${pkgs.systemd}/bin/systemctl suspend"; }
        # { timeout = 1200; command = "${pkgs.sway}/bin/swaymsg \"output * toggle\""; }
      ];
    };

    # Force systemd to not care about the WAYLAND_DISPLAY env variable.
    systemd.user.services.swayidle = {
      Unit.ConditionEnvironment = lib.mkForce ""; # Updated.
    };
  };
}
