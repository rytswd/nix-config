{ config, lib, ... }:
# Assumes the security bundle (which always imports sops-nix.nix) is also
# imported by the host -- sops.templates below relies on the sops module.
#
# The sync config is the canonical ephemeral-class secret (see
# user-config/modules/lib/secrets.nix): hosts enrolled with a per-instance
# key (`local.secrets.tier = "ephemeral"`) get sync just like YubiKey
# hosts. When ephemeral-class secrets aren't available at all (e.g.
# SSH-only coder workspaces) the sync config can't be decrypted, so we
# write a plain local-only config instead and skip atuin sync entirely.
{
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

  # SOPS Nix based secret handling -- generate the config with secrets
  # substituted in.
  sops.templates."atuin-config" = lib.mkIf config.local.secrets.ephemeralAvailable {
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

  # Keyless fallback (no sync server address to decrypt) -- local history
  # only. Same target path as the sops template above; mutually exclusive.
  xdg.configFile."atuin/config.toml" = lib.mkIf (!config.local.secrets.ephemeralAvailable) {
    text = ''
      auto_sync = false
      enter_accept = false
      filter_mode_shell_up_key_binding = "session"
      search_mode = "fuzzy"
    '';
  };
}
