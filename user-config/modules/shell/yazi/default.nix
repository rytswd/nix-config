{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    shell.yazi.enable = lib.mkEnableOption "Enable Yazi.";
  };

  config = lib.mkIf config.shell.yazi.enable {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    # Because of the limitation around Zoxide not handling the argument cleanly,
    # I'm adding an extra function to work out the change directory logic with
    # Yazi for each shell.
    programs.zsh.initContent = ''
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                cd "$cwd"
        fi
        rm -f -- "$tmp"
    }
    '';
    programs.fish.interactiveShellInit = ''
      function yy -d "Run Yazi wrapper for Zoxide"
        set -l tmp "$(mktemp -t "yazi-cwd.XXXXXX")"
        command yazi --cwd-file=$tmp
        if set -l cwd "$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]
            cd "$cwd"
        end
        rm -f -- "$tmp"
    end
    '';
    programs.bash.initExtra = ''
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                cd "$cwd"
        fi
        rm -f -- "$tmp"
    }
    '';

    xdg.configFile = {
      "yazi/yazi.toml".source = ./yazi.toml;
      "yazi/keymap.toml".source = ./keymap.toml;
    };
  };
}
