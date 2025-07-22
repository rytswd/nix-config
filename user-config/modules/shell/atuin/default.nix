{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.atuin.enable = lib.mkEnableOption "Enable Atuin.";
  };

  config = let
    # Base setup
    base = lib.mkIf config.shell.atuin.enable {
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

        # NOTE: Because of the lack of secret handling, I'm using XDG file with
        # SOPS Nix.
        # settings = {
        #   auto_sync = true;
        #   sync_frequency = "5m";
        #   sync_address = "REDACTED;
        #   search_mode = "fuzzy";
        #   filter_mode_shell_up_key_binding = "session";
        #   enter_accept = false; # Do not immediately execute
        # };
      };
    };

    # SOPS Nix based secret handling
    withSops = lib.mkIf config.security.sops-nix.enable {
      # Use sops.templates to generate the config with secrets substituted.
      sops.templates."atuin-config" = {
        # With file input like this, the file is expected to have the following
        # placeholder string:
        #
        #     <SOPS:**SHA256_OF_SECRET**:PLACEHOLDER>
        #
        # And SHA256 can be generated using
        #
        #     nix repl
        #     > builtins.hashString "sha256" "SECRET_NAME"
        #
        file = ./config.toml;
        path = "${config.xdg.configHome}/atuin/config.toml";
      };
    };
  in lib.mkMerge [
    base
    withSops
  ];
}
