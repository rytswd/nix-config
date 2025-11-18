{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    launcher.anyrun.enable = lib.mkEnableOption "Enable Anyrun.";
  };

  config = lib.mkIf config.launcher.anyrun.enable {
    programs.anyrun = {
      enable = true;
      config = {
        x = { fraction = 0.5; };
        y = { fraction = 0.3; };
        width = { fraction = 0.3; };
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = false;
        showResultsImmediately = false;
        maxEntries = null;

        plugins = [
          "${pkgs.anyrun}/lib/libapplications.so"
          "${pkgs.anyrun}/lib/libsymbols.so"
          "${pkgs.anyrun}/lib/libniri_focus.so"
          "${pkgs.anyrun}/lib/libdictionary.so"
          "${pkgs.anyrun}/lib/libtranslate.so"
          "${pkgs.anyrun}/lib/librink.so"
        ];
      };

      # Default CSS taken from https://github.com/anyrun-org/anyrun/blob/master/anyrun/res/style.css
      extraCss = /*css */ ''
        @define-color accent #5599d2;
        @define-color bg-color #161616;
        @define-color fg-color #eeeeee;
        @define-color desc-color #cccccc;

        window {
          background: transparent;
        }

        box.main {
          padding: 5px;
          margin: 10px;
          border-radius: 10px;
          border: 2px solid @accent;
          background-color: @bg-color;
          box-shadow: 0 0 5px black;
        }

        text {
          min-height: 30px;
          padding: 5px;
          border-radius: 5px;
          color: @fg-color;
        }

        .matches {
          background-color: rgba(0, 0, 0, 0);
          border-radius: 10px;
        }

        box.plugin:first-child {
          margin-top: 5px;
        }

        box.plugin.info {
          min-width: 200px;
        }

        list.plugin {
          background-color: rgba(0, 0, 0, 0);
        }

        label.match {
          color: @fg-color;
        }

        label.match.description {
          font-size: 10px;
          color: @desc-color;
        }

        label.plugin.info {
          font-size: 14px;
          color: @fg-color;
        }

        .match {
          background: transparent;
        }

        .match:selected {
          border-left: 4px solid @accent;
          background: transparent;
          animation: fade 0.1s linear;
        }

        @keyframes fade {
          0% {
            opacity: 0;
          }

          100% {
            opacity: 1;
          }
        }
      '';

      # extraConfigFiles."some-plugin.ron".text = ''
      #   Config(
      #   // for any other plugin
      #   // this file will be put in ~/.config/anyrun/some-plugin.ron
      #   // refer to docs of xdg.configFile for available options
      # )
      # '';
    };
  };
}
