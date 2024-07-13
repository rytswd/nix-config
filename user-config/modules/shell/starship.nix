{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.starship.enable = lib.mkEnableOption "Enable Starship.";
  };

  config = lib.mkIf config.shell.starship.enable {
    programs.starship = {
        enable = true;
        # Starship configuration can be defined with the `settings` attribute, but
        # as it is not as intuitive as TOML format, I'm rather simply copying the
        # TOML file over using `xdg.configFile`.
        # settings = { SOME NIX LANG BASED SETTING };

        # Specifically turning off ZSH integration, as Powerlevel10k provides
        # better feedback.
        enableZshIntegration = false;
      };

    xdg.configFile = {
      # Instead of using programs.starship.settings, copying the TOML file over,
      # as it is easier to parse as is.
      "starship.toml".source = ./starship/starship.toml;
    };
  };
}
