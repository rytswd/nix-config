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
        {
          # This is needed when suspend is called by other logic, such as lid close.
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
        }
      ];
      timeouts = [
        # 10 min
        {
          timeout = (60 * 10);
          # TODO: This is specific to the Asus machine, I will need to move this
          # definition somewhere else.
          command = "${pkgs.brightnessctl}/bin/brightnessctl -d \"amdgpu_bl*\" set 5% -s";
          resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -d \"amdgpu_bl*\" -r";
        }
        # 15 min
        {
          timeout = (60 * 15);
          # NOTE: The swaylock -f flag is necessary to free up swayidle to
          # process further suspention.
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
        }
        # 20 min
        {
          timeout = (60 * 20);
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        # TODO: Hibernate setup needs more tweaking, and thus commenting out for now.
        # {
        #   timeout = (60 * 30);
        #   command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
        # }
      ];
    };

    # Force systemd to not care about the WAYLAND_DISPLAY env variable.
    systemd.user.services.swayidle = {
      Unit.ConditionEnvironment = lib.mkForce ""; # Updated.
    };
  };
}
