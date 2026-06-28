{
  pkgs,
  config,
  lib,
  ...
}:
# Assumes the security bundle (which always imports sops-nix.nix) is also
# imported by the host -- sops.templates below relies on the sops module.
# Keyless hosts (e.g. coder) manage jj config separately and don't import
# this module.
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
  #
  # Core-class template: gated on `coreAvailable` so ephemeral-tier hosts
  # (per-instance key, no YubiKey -- see lib/secrets.nix) that import the
  # vcs bundle simply get no jj config instead of failing at activation.
  # No fallback on purpose: hosts without core secrets manage jj config by
  # hand if they need one, same as keyless hosts always have.
  sops.templates."jujutsu-config" = lib.mkIf config.local.secrets.coreAvailable {
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
