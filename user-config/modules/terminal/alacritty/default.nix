{ pkgs, ... }:
{
  programs.alacritty.enable = true;
  xdg.configFile = {
    "alacritty/alacritty.toml".source =
      if pkgs.stdenv.isDarwin
      then ./macos.toml
      else ./nixos.toml;
  };
}
