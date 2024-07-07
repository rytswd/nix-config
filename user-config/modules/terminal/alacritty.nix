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
      configFile = {
        "alacritty/alacritty.toml".source =
          if pkgs.stdenv.isDarwin
          then ./alacritty-for-macos.toml
          else ./alacritty-for-nixos.toml;
      };
    };
  };
}
