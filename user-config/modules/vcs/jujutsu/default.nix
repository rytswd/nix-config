{ pkgs
, lib
, config
, ...}:

{
  options = {
    vcs.jujutsu.enable = lib.mkEnableOption "Enable Jujutsu related items.";
  };

  config = let
    # Base setup
    base = lib.mkIf config.vcs.jujutsu.enable {
      # NOTE: I'm not enabling the programs here, as it would not work with the
      # manual configuration with TOML.
      # programs.jujutsu = {
      #   enable = true;
      # };
      home.packages = [
        pkgs.jujutsu
        pkgs.lazyjj
      ];
    };

    # SOPS Nix based secret handling
    withSops = lib.mkIf config.security.sops-nix.enable {
      # Use sops.templates to generate the config with secrets substituted.
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
    };
  in lib.mkMerge [
    base
    withSops
  ];
}
