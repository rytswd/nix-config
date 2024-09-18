{ pkgs
, lib
, config
, ...}:

{
  options = {
    vcs.jujutsu.enable = lib.mkEnableOption "Enable Jujutsu related items.";
  };

  config = lib.mkIf config.vcs.jujutsu.enable {
    programs.jujutsu = {
      enable = true;
    };
    xdg.configFile = {
      "jj".source = ./jujutsu;
      "jj".recursive = true;
    };
  };
}
