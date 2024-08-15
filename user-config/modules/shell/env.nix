{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.env.enable = lib.mkEnableOption "Enable environment valiables.";
  };

  config = lib.mkIf config.shell.env.enable {
    home.sessionVariables = {
      # Although I use Emacs for my main driver, I want to ensure that this
      # editor choice works in any environment, even when Emacs server is not
      # running. I could use `emacs -nw`, but for now, as my Emacs configuration
      # only works for GUI version, using nvim as the default works for me.
      EDITOR = "nvim";

      # less
      #   -i: Case insensitive
      #   -M: Use long prompt
      #   -N: Show line numbers
      #   -R: Use raw input for colour escape sequence
      # Line number is not used as of writing, as it is annoying for man.
      LESS = "-iMR";

      # ripgrep
      RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";

      # fzf
      FZF_CTRL_T_OPTS="
        --preview 'bat -n --color=always {}'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'";
      # alt+c: fzf based cd, which can be triggered at any time to change dir.
      FZF_ALT_C_OPTS = "--preview 'tree -C {}'";

      # man using bat
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };
  };
}
