{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.atuin.enable = lib.mkEnableOption "Enable Atuin.";
  };

  config = lib.mkIf config.shell.atuin.enable {
    programs.atuin = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      # NOTE: If I want to get rid of the binding, I can add below.
      # flags = [
      #   "--disable-up-arrow"
      # ];
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        filter_mode_shell_up_key_binding = "session";
        enter_accept = false; # Do not immediately execute
      };
    };
  };
}
