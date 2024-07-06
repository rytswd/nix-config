{ pkgs
, lib
, config
, inputs
, system
, ...}:

{
  options = {
    launcher.fuzzel.enable = lib.mkEnableOption "Enable Fuzzel.";
  };

  config = lib.mkIf config.launcher.fuzzel.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "FiraCode Nerd Font:size=10";
          width = 80;
          terminal = "${inputs.ghostty.packages.${system}.default}/bin/ghostty";
          layer = "overlay";
        };
        colors = {
          background = "#222222dd";
          selection = "#221865cc";
        };
        border = {
          radius = 7;
        };
        key-bindings = {
          # In order to respect the CapsLock being control, I need to list out
          # both the lower and upper case characters.
          cancel = "Control+g Control+G Escape";
          cursor-end = "Control+e Control+E";
          cursor-home = "Control+a Control+A";
          prev = "Up Control+p Control+P";
          next = "Down Control+n Control+N";
        };
      };
    };
  };
}
