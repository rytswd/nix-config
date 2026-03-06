{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.github.enable = lib.mkEnableOption "Enable GitHub related tooling.";
  };

  config = lib.mkIf config.service.github.enable {
    programs.gh = {
      enable = true;
    };
  };
}
