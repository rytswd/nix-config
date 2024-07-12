{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.tmux.enable = lib.mkEnableOption "Enable Tmux.";
  };

  config = lib.mkIf config.shell.tmux.enable {
    # NOTE: I'm not using Tmux anymore, and thus the following setup is rather
    # stale.
    programs.tmux = {
      enable = true;
      plugins = let
        resurrectLatest =  pkgs.tmuxPlugins.mkTmuxPlugin {
          pluginName = "resurrect";
          version = "master";
          src = pkgs.fetchFromGitHub {
            owner = "tmux-plugins";
            repo = "tmux-resurrect";
            rev = "a2ddfb96b94bb64a7a2e3f5fa2a7c57dce8ad579"; # Using the latest commit as of Jan 2023
            hash = "sha256-DFDdTMwRQXk9g3OlP/3JAw5iPaeK4Cks06QFZVP6iL0=";
          };
        }; in
        with pkgs.tmuxPlugins; [
          nord
          # resurrect # Commented out to use the latest version instead
          {
            plugin = better-mouse-mode;
            extraConfig = ''
              # Keep copy mode when scrolling down
              set -g @scroll-down-exit-copy-mode "off"

              # Set scroll speed to be 1 line at a time
              set -g @scroll-speed-num-lines-per-scroll 1

              # Disable tmux scroll when in less, more, man, etc.
              set -g @emulate-scroll-for-no-mouse-alternate-buffer on
            '';
          }
        ] ++ [
          resurrectLatest
        ];
      extraConfig = builtins.readFile ./tmux/tmux.conf;
    };
  };
}
