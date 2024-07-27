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
      "swaylock-effects" = "swaylock \
                             --screenshots \
                             --clock \
                             --indicator \
                             --indicator-radius 100 \
                             --indicator-thickness 7 \
                             --effect-blur 7x5 \
                             --effect-vignette 0.5:0.5 \
                             --ring-color bb00cc \
                             --key-hl-color 880033 \
                             --line-color 00000000 \
                             --inside-color 00000088 \
                             --separator-color 00000000 \
                             --grace 2 \
                             --fade-in 0.2";
    };
  };
}
