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
    home.packages = [
      # NOTE: lazyjj failing build
      # Ref: https://github.com/NixOS/nixpkgs/issues/370890
      # pkgs.lazyjj
    ];
    xdg.configFile = {
      "jj".source = ./jujutsu;
      "jj".recursive = true;
    };
  };
}
