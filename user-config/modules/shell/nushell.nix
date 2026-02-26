{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.nushell.enable = lib.mkEnableOption "Enable Nushell.";
  };

  config = lib.mkIf config.shell.nushell.enable {
    programs.nushell = {
      enable = true;
      shellAliases =
        # NOTE: Using dedicated alias definitions for Nushell.
        # (import ./aliases-ls.nix { withEza = true; }) //
        {
          # NOTE: Because of the way Nushell aliases work, Nushell cannot make
          # use of the `home.shellAliases` like other shells. I need to list
          # out all the aliases I use here instead.
          # Ref: https://github.com/nix-community/home-manager/pull/4616#issuecomment-1817812397
          k = "kubectl";
          gccact = "gcloud config configurations activate";
          gccls = "gcloud config configurations list";
          tf = "terraform";
        };
      settings = {
        show_banner = false;
        history.file_format = "sqlite";
        completions = {
          case_sensitive = false;
          algorithm = "fuzzy";
        };
        keybindings = [
          {
            name = "insert_last_word";
            modifier = "alt";
            keycode = "char_.";
            mode = ["emacs" "vi_normal" "vi_insert"];
            event = [
              # NOTE: In other shells, this should cycle through to use last
              # argument from the previous commands, but with the below code
              # it doesn't do that.
              { edit = "InsertString"; value = " !$"; }
              { send = "enter"; }
            ];
          }
          {
            name = "duplicate_word";
            modifier = "alt";
            keycode = "char_m";
            mode = ["emacs" "vi_normal" "vi_insert"];
            event = [
              {
                cmd = "commandline --insert (commandline | str substring 0..(commandline --cursor) | str trim | split row ' ' | last)";
                send = "executehostcommand";
              }
            ];
          }
        ];
      };
      extraConfig = ''
        def l [i = .] { ls $i | sort-by type }
        def ll [i = .] { ls -l $i | sort-by type }
        def la [i = .] { ls -la $i | sort-by type }
      '';
    };

    xdg.configFile = {
      # Plugin setup
      # Not sure if this is the best way, but this works well enough.
      # Upon creating these binary references, I need to instruct Nushell to
      # use them:
      #
      #     plugin add nu_plugin_dbus
      #     plugin use dbus
      #
      # TODO: version marked as broken
      # Ref: https://github.com/devyn/nu_plugin_dbus/issues/11
      # Ref: https://github.com/devyn/nu_plugin_dbus/pull/12
      # "nushell/plugins/nu_plugin_dbus".source = "${pkgs.nushellPlugins.dbus}/bin/nu_plugin_dbus";
      "nushell/plugins/nu_plugin_polars".source = "${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars";
    };
  };
}
