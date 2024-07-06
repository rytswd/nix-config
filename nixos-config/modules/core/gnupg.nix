{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.gnupg.enable = lib.mkEnableOption "Enable GnuPG and Yubikey.";
  };

  config = lib.mkIf config.core.gnupg.enable {
    programs.gnupg.agent = {
      enable = true;
      # enableSSHSupport = true;
    };
    services.yubikey-agent.enable = true;
  };
}
