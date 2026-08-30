{ pkgs, ... }:
{
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
      history = {
        file_format = "sqlite";
        sync_on_enter = true;
        isolation = true;
      };
      completions = {
        case_sensitive = false;
        algorithm = "fuzzy";
      };
      keybindings = [
        {
          name = "insert_last_word";
          modifier = "alt";
          keycode = "char_.";
          mode = [
            "emacs"
            "vi_normal"
            "vi_insert"
          ];
          event = [
            # NOTE: In other shells, this should cycle through to use last
            # argument from the previous commands, but with the below code
            # it doesn't do that.
            {
              edit = "InsertString";
              value = " !$";
            }
            { send = "enter"; }
          ];
        }
        {
          name = "duplicate_word";
          modifier = "alt";
          keycode = "char_m";
          mode = [
            "emacs"
            "vi_normal"
            "vi_insert"
          ];
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
      # NOTE: the `: path` annotations matter. With `completions.algorithm =
      # "fuzzy"`, an untyped positional makes Nushell fuzzy-match the whole
      # buffer against every command name in scope -- including the hundreds
      # of multi-word subcommands from the vendor autoload completions (jj,
      # niri, starship, ...) -- so `l s`<TAB> listed ~500 commands instead of
      # the files. Declaring the shape as `path` forces path completion.
      def l [i: path = .] { ls $i | sort-by type }
      def ll [i: path = .] { ls -l $i | sort-by type }
      def la [i: path = .] { ls -la $i | sort-by type }
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

    # TODO: re-enable once the nixpkgs-unstable channel moves past
    # 2026-08-05. nu_plugin_polars 0.114.1 pins ethnum 1.5.2, whose
    # `mem::transmute::<(), TryFromIntError>(())` stopped compiling on
    # rustc 1.97, so the derivation fails to build -- and because
    # home-manager here follows nixpkgs-unstable, that took every host with
    # this module down in CI. The fix (ethnum 1.5.3) is merged upstream in
    # NixOS/nixpkgs#546343, but the channel is still parked on 2026-08-03,
    # so no amount of `nix flake update` picks it up yet.
    #
    # Not overriding the package in an overlay to carry the same cargo
    # lockfile patch: that trades a cached build for a from-source polars
    # rebuild on every host, for a plugin that still has to be registered
    # by hand (`plugin add nu_plugin_polars`).
    # Ref: https://github.com/NixOS/nixpkgs/issues/546250
    # "nushell/plugins/nu_plugin_polars".source = "${pkgs.nushellPlugins.polars}/bin/nu_plugin_polars";
  };
}
