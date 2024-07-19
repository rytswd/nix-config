{ pkgs
, lib
, config
, ...}:

{
  options = {
    communication.discord.enable = lib.mkEnableOption "Enable Discord.";
  };

  config = lib.mkIf config.communication.discord.enable {
    # Instead of using the official Discord app, I'm making use of Vesktop.
    # Discord seems to have less support around Wayland environment.
    home.packages = [ pkgs.vesktop ];
  };
}
