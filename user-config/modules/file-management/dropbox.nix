{ pkgs
, lib
, config
, ...}:

{
  options = {
    file-management.dropbox.enable = lib.mkEnableOption "Enable Dropbox.";
  };

  config = let
    # Base setup
    base = lib.mkIf config.file-management.dropbox.enable {
      home.packages =
        if pkgs.stdenv.isDarwin
        then []
        # NOTE: I couldn't make Dropbox to work in Linux env. For now, Maestral
        # does what I need.
        else [ pkgs.maestral ];

      # TODO: Configure systemd to start maestral daemon.
    };

    # SOPS Nix based secret handling
    withSops = lib.mkIf config.security.sops-nix.enable {
      # Use sops.templates to generate the config with secrets substituted.
      sops.templates."maestral-config" = {
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
        file = ./maesral.ini;
        path = "${config.xdg.configHome}/maestral/maestral.ini";
      };
    };
  in lib.mkMerge [
    base
    withSops
  ];
}
