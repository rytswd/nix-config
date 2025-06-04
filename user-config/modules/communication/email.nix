{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.email.enable = lib.mkEnableOption "Enable Email tooling.";
  };

  config = lib.mkIf config.communication.email.enable {
    home.packages = [
      pkgs.mu
      pkgs.isync
      pkgs.msmtp
    ];
    programs.notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync -a";
      };
    };
  };
}
