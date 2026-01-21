{ pkgs
, lib
  , config
  , inputs
, ...}:

{
  options = {
    # NOTE:
    # PAM (Pluggable Authentication Module) that integrates U2F (Universal 2nd Factor)
    security.pam-u2f.enable = lib.mkEnableOption "Enable PAM U2F setup.";
  };

  config = lib.mkIf (config.security.pam-u2f.enable && config.security.sops-nix.enable) {
    sops.secrets."yubikey-pam-u2f" = let
      private-repo = (builtins.toString inputs.nix-config-private);
    in {
      sopsFile = "${private-repo}/keys/yubikey/pam-u2f.yaml";
      key = "data";
      path = "${config.xdg.configHome}/Yubico/u2f_keys";
    };
  };
}
