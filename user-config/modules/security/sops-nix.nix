{ pkgs
, lib
, config
, inputs
, ...}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options = {
    security.sops-nix.enable = lib.mkEnableOption "Enable SOPS Nix setup.";
  };

  config = lib.mkIf config.security.sops-nix.enable {
    sops = let
      private-repo = (builtins.toString inputs.nix-config-private);
    in {
      defaultSopsFile = "${private-repo}/secrets/main.yaml";
      defaultSopsFormat = "yaml";

      # NOTE: The key file here is based on YubiKey, and as of writing in 2025,
      # key with passphrase does not work well with SOPS Nix. For that reason,
      # I opted to create a dedicate age recipient for each machine I need,
      # and use multiple recipient support by age / SOPS.
      # Ref: https://github.com/Mic92/sops-nix/issues/377
      # age.keyFile = "${home}/.config/sops/age/keys.txt";

      # NOTE: This local key needs to be generated manually, and also the
      # recipient key needs to be added to the SOPS encrypted secrets.
      #
      #     mkdir -p $XDG_DATA_HOME/sops/age
      #     age-keygen -o $XDG_DATA_HOME/sops/age/local-keys.txt
      #
      # The age recipient key generated should only be passed to the private
      # repo with SOPS encryption target.
      age.keyFile = "${config.xdg.dataHome}/sops/age/local-keys.txt";

      age.plugins = [ pkgs.age-plugin-yubikey ];

      secrets = {
        "email/main-1" = {};
        "email/main-2" = {};
        "email/main-3" = {};
        "email/personal-1" = {};
        "email/personal-2" = {};
        "email/gaming-1" = {};
        "email/gaming-2" = {};

        "services/atuin/endpoint" = {};

        # # Work related
        # "email/work-1" = {
        #   sopsFile = "${private-repo}/secrets/work.yaml";
        # };
      };
    };
  };
}
