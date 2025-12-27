# macOS specific Home Manager configurations

{ config
, pkgs
, inputs
, ... }:

let username = "ryota";
in {
  imports = [
    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    ../modules/shell
    ../modules/git-clone
    ../modules/key-remap/skhd

    ../modules/terminal
    ../modules/bar
    ../modules/window-manager
    ../modules/vcs
    ../modules/editor
    ../modules/programming
    ../modules/security
    ../modules/kubernetes
    ../modules/service
    ../modules/dictionary
    ../modules/communication
    ../modules/image
  ];
  ###----------------------------------------
  ##   Module related options
  #------------------------------------------
  kubernetes.extra.enable = true;
  communication.slack.enable = true;

  # macOS specific ones
  # bar.sketchybar.enable = true; # Changing since macOS Tahoe
  editor.zed.enable = false; # Known issue with macOS
  window-manager.yabai.enable = true;

  ###----------------------------------------
  ##   Other Home Manager Setup
  #------------------------------------------
  programs.home-manager.enable = true;
  xdg.enable = true;

  # TODO: Move this somewhere.
  programs.gpg.enable = true;

  home = {
    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages =
      [
        ###------------------------------
        ##   UI Tools
        #--------------------------------
        pkgs.discord
        pkgs.zoom-us

        ###------------------------------
        ##   macOS Specific
        #--------------------------------
        pkgs.skhd       # https://github.com/koekeishiya/skhd
        pkgs.yabai      # https://github.com/koekeishiya/yabai

        pkgs.pngpaste   # https://github.com/jcsalterego/pngpaste

        pkgs.utm

        # I don't use this anymore.
        # pkgs.stats      # https://github.com/exelban/stats

        ###------------------------------
        ##   Extra Setup
        #--------------------------------
        pkgs.vscode-insiders   # Added from the overlay setup
      ];

    stateVersion = "23.11";
  };

  # Startup Processes
  launchd.agents = {
    # ollama = {
    #   enable = true;
    #   config = {
    #     ProgramArguments = [
    #       "${pkgs.ollama}/bin/ollama"
    #       "serve"
    #     ];
    #     # Always keep it running.
    #     KeepAlive = true;
    #     RunAtLoad = true;
    #     ProcessType = "Background";
    #     WorkingDirectory = "/tmp/";
    #   };
    # };
    pueue = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.pueue}/bin/pueued"
        ];
        # Always keep it running.
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        WorkingDirectory = "/tmp/";
      };
    };
    yabai = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.yabai}/bin/yabai"
          "-c"
          "${config.xdg.configHome}/yabai/yabairc"
        ];
        EnvironmentVariables = {
          # Ensure PATH is correctly handled
          PATH = pkgs.lib.concatStringsSep ":" [
            "/Users/${username}/.nix-profile/bin"
            "/etc/profiles/per-user/${username}/bin"
            "/run/current-system/sw/bin"
            "/nix/var/nix/profiles/default/bin"
            "/usr/local/bin"
            "/usr/bin"
            "/usr/sbin"
            "/bin"
            "/sbin"
          ];
        };
        # Although I would usually want to keep it runnig, yabai, upon startup,
        # updates the window configuration of any open windows. That would be
        # really annoying, and would want to keep it stopped.
        KeepAlive = false;
        RunAtLoad = true;
        WorkingDirectory  = "/tmp/";
        StandardOutPath   = "/tmp/yabai.log";
        StandardErrorPath = "/tmp/yabai.log";
      };
    };
    skhd = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.skhd}/bin/skhd"
          "-c"
          "${config.xdg.configHome}/skhd/skhdrc"
        ];
        KeepAlive = {
          # When stopped with launchctl, keep it stopped.
          # Otherwise try to restart at all time.
          SuccessfulExit = false;
        };
        RunAtLoad = true;
        WorkingDirectory  = "/tmp/";
        StandardOutPath   = "/tmp/skhd.log";
        StandardErrorPath = "/tmp/skhd.log";
      };
    };
    # sketchybar = {
    #   enable = true;
    #   config = {
    #     ProgramArguments = [
    #       "${pkgs.sketchybar}/bin/sketchybar"
    #       "-c"
    #       "${config.xdg.configHome}/sketchybar/sketchybarrc.nu"
    #     ];
    #     EnvironmentVariables = {
    #       # Ensure PATH is correctly handled
    #       PATH = pkgs.lib.concatStringsSep ":" [
    #         "/Users/${username}/.nix-profile/bin"
    #         "/etc/profiles/per-user/${username}/bin"
    #         "/run/current-system/sw/bin"
    #         "/nix/var/nix/profiles/default/bin"
    #         "/usr/local/bin"
    #         "/usr/bin"
    #         "/usr/sbin"
    #         "/bin"
    #         "/sbin"
    #       ];
    #     };
    #     # Although I would usually want to keep it runnig, there are cases where
    #     # I want to test updating some configurations. For that, it's best to
    #     # stop using Nix based version and run a local process instead.
    #     KeepAlive = false;
    #     RunAtLoad = true;
    #     WorkingDirectory  = "/tmp/";
    #     StandardOutPath   = "/tmp/sketchybar.log";
    #     StandardErrorPath = "/tmp/sketchybar.log";
    #   };
    # };
  };
}
