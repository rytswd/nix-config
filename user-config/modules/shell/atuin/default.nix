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

      flags = [
        # The up arrow binding gets triggered by mistake, and while I tried to
        # adopt for some time, I found it more annoying than useful. When I
        # need to check the actual history, I will be sending an explicit keys
        # and that would give me better control.
        "--disable-up-arrow"
      ];
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
