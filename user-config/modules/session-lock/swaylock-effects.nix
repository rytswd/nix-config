{ pkgs
, lib
, config
, ...}:

{
  options = {
    session-lock.swaylock-effects.enable = lib.mkEnableOption "Enable swaylock-effects, a fork of swaylock.";
  };

  config = lib.mkIf config.session-lock.swaylock-effects.enable {
    home.packages = [
      pkgs.swaylock-effects
    ];
    home.shellAliases = {
      "swaylock-effects" = "swaylock"
                           + " --screenshots"
                           + " --clock"
                           + " --indicator"
                           + " --indicator-radius 70"
                           + " --indicator-thickness 4"
                           + " --effect-blur 7x5"
                           + " --effect-vignette 0.5:0.5"
                           + " --ring-color 006BA6"
                           + " --key-hl-color 0496FF"
                           + " --line-color 00000000"
                           + " --inside-color 00000088"
                           + " --separator-color 00000000"
                           + " --grace 1"
                           + " --fade-in 0.2";
    };
  };
}
