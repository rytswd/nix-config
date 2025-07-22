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
      shellAliases = (import ./aliases-ls.nix { withEza = true; }) //
        {
          # Any aliases specific for fish can be defined here.
          # NOTE: Because of the way Nushell aliases work, Nushell cannot make
          # use of the `home.shellAliases` like other shells. I need to list
          # out all the aliases I use here instead.
          # Ref: https://github.com/nix-community/home-manager/pull/4616#issuecomment-1817812397
          k = "kubectl";
          gccact = "gcloud config configurations activate";
          gccls = "gcloud config configurations list";
          tf = "terraform";
        };
      configFile = {
        text = ''
           $env.config = {
            show_banner: false
          }
        '';
        };
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
