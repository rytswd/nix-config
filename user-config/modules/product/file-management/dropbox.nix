{ pkgs, config, ... }:
# Assumes the security bundle (which always imports sops-nix.nix) is also
# imported by the host -- sops.templates below relies on the sops module.
{
  home.packages =
    if pkgs.stdenv.isDarwin then
      [ ]
    # NOTE: I couldn't make Dropbox to work in Linux env. For now, Maestral
    # does what I need.
    else
      [ pkgs.maestral ];

  # TODO: Configure systemd to start maestral daemon.

  # SOPS Nix based secret handling.
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
    file = ./maestral.ini;
    path = "${config.xdg.configHome}/maestral/maestral.ini";
  };
}
