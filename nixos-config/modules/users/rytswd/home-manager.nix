# This is a placeholder file only.
{ pkgs, ...}:

{
    home.packages = with pkgs; [
        # Linux basic setup
        rofi
        tmux
        alacritty

        # Utilities
        tree
        vim
        watch

        # # Sway related
        # swaylock
        # swayidle
        # mako

        # Coding
        go
    ];

    # File mapping
    home.file.".alacritty.yml".text = builtins.readFile ./configs/alacritty.yml;
    xdg.configFile."greenclip.toml".text = builtins.readFile ./configs/greenclip.toml;
    xdg.configFile."i3/config".text = builtins.readFile ./configs/i3;
    xdg.configFile."rofi/config.rasi".text = builtins.readFile ./configs/rofi;
    xresources.extraConfig = builtins.readFile ./configs/Xresources;

    # Core programs
    programs.alacritty = {
        enable = true;

        settings = {
            env.TERM = "xterm-256color";

            key_bindings = [
                { key = "K"; mods = "Command"; chars = "ClearHistory"; }
                { key = "V"; mods = "Command"; action = "Paste"; }
                { key = "C"; mods = "Command"; action = "Copy"; }
                { key = "Key0"; mods = "Command"; action = "ResetFontSize"; }
                { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
            ];
        };
    };
    
    programs.kitty = {
        enable = true;
        extraConfig = builtins.readFile ./configs/kitty;
    };

    programs.git = {
        enable = true;

        userName = "Ryota";
        userEmail = "rytswd@gmail.com";
        aliases = {
            prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
            root = "rev-parse --show-toplevel";
        };
        extraConfig = {
            branch.autosetuprebase = "always";
            color.ui = true;
            core.askPass = ""; # needs to be empty to use terminal for ask pass
            credential.helper = "store"; # want to make this more secure
            github.user = "rytswd";
            push.default = "tracking";
            init.defaultBranch = "main";
        };
    };

    programs.i3status = {
        enable = true;

        general = {
            colors = true;
            color_good = "#8C9440";
            color_bad = "#A54242";
            color_degraded = "#DE935F";
        };

        modules = {
            ipv6.enable = false;
            "wireless _first_".enable = false;
            "battery all".enable = false;
        };
    };

    # Wayland + Sway
    # Could not get this to work, so disabling this for now. May need to revisit at one point.
    # wayland.windowManager.sway = {
    #     enable = true;
    #     wrapperFeatures.gtk = true;
    # };

    programs.gpg.enable = true;

    # Shells
    programs.bash = {
        enable = true;
        shellOptions = [];
        historyControl = [ "ignoredups" "ignorespace" ];
        initExtra = builtins.readFile ./configs/bashrc;

        shellAliases = {
            ga = "git add";
            gc = "git commit";
            gco = "git checkout";
            gcp = "git cherry-pick";
            gdiff = "git diff";
            gl = "git prettylog";
            gp = "git push";
            gs = "git status";
            gt = "git tag";
        };
    };

    programs.zsh.enable = true;

    # Other
    programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
            golang.go
            github.copilot
            #file-icons.file-icons
        ];
    };

}
