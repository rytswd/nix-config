{ pkgs
, lib
, config
, ...}:

{
  options = {
    bar.waybar.enable = lib.mkEnableOption "Enable Waybar.";
  };

  config = lib.mkIf config.bar.waybar.enable {
    programs.waybar = {
      enable = true;

      # I'm making an explicit systemd entry as per below.
      systemd.enable = false;

      # NOTE: I'm not using the Nix based definitions as it was easier to test
      # using direct jsonc and css inputs.
    };

    xdg.configFile = {
      "waybar".source = ./config;
      "waybar".recursive = true;
    };

    systemd.user.services = {
      waybar_top = {
        Unit.Description = "Waybar for top part.";

        Service = {
          Restart = "on-failure";
          ExecStart = ''
          ${pkgs.waybar}/bin/waybar \
            -c ${config.xdg.configHome}/waybar/config_top.jsonc \
            -s ${config.xdg.configHome}/waybar/style_top.css
          '';
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          KillMode = "mixed";
        };

        Install.WantedBy = [ "default.target" ];
      };

      waybar_bottom = {
        Unit.Description = "Waybar for bottom part.";

        Service = {
          Restart = "on-failure";
          ExecStart = ''${pkgs.waybar}/bin/waybar \
            -c ${config.xdg.configHome}/waybar/config_bottom.jsonc \
            -s ${config.xdg.configHome}/waybar/style_bottom.css'';
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          KillMode = "mixed";
        };

        Install.WantedBy = [ "default.target" ];
      };

      waybar_left = {
        Unit = {
          Description = "Waybar for left part.";
          # Because left bar can affect the look of the top and bottom, I am
          # ensuring that the top and bottom bars are handled first.
          After = [ "waybar_top.service" "waybar_bottom.service" ];
          Requires = [ "waybar_top.service" "waybar_bottom.service" ];
        };

        Service = {
          Restart = "on-failure";
          ExecStart = ''${pkgs.waybar}/bin/waybar \
            -c ${config.xdg.configHome}/waybar/config_left.jsonc \
            -s ${config.xdg.configHome}/waybar/style_left.css'';
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          KillMode = "mixed";
        };

        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}
