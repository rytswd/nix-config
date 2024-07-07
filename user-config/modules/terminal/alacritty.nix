{ pkgs
, lib
, config
, ...}:

{
  options = {
    terminal.alacritty.enable = lib.mkEnableOption "Enable Alacritty.";
  };

  config = lib.mkIf config.terminal.alacritty.enable {
    programs.alacritty = {
      enable = true;
    };
    xdg = {
      enable = true;
      configFile = {
        "alacritty/alacritty.toml".source =
          if pkgs.stdenv.isDarwin
          then ./alacritty-for-macos.conf
          else ./alacritty-for-nixos.conf;
      };
    };
  };
}
