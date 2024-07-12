{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.direnv.enable = lib.mkEnableOption "Enable Direnv.";
  };

  config = lib.mkIf config.shell.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    xdg.configFile = {
      "direnv/direnv.toml".source = ./direnv/direnv.toml;
    };
  };
}
