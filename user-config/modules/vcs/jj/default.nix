{ pkgs, config, ... }:
# Assumes the security bundle (which always imports sops-nix.nix) is also
# imported by the host -- sops.templates below relies on the sops module.
{
  # NOTE: I'm not enabling the programs here, as it would not work with the
  # manual configuration with TOML.
  # programs.jujutsu = {
  #   enable = true;
  # };
  home.packages = [
    pkgs.jujutsu
    pkgs.lazyjj
  ];

  # SOPS Nix based secret handling -- generate the config with secrets
  # substituted in.
  sops.templates."jujutsu-config" = {
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
    path = "${config.xdg.configHome}/jj/config.toml";
  };
}
