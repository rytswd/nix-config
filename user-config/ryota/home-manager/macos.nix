# macOS specific Home Manager configurations

{ config
, pkgs
, ... }:

let username = "ryota";
in {
  imports = [
    ./common.nix
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages =
      [
        ###------------------------------
        ##   UI Tools
        #--------------------------------
        pkgs.discord
        pkgs.slack
        pkgs.zoom-us
      ]
      ++ [
        ###------------------------------
        ##   macOS Specific
        #--------------------------------
        pkgs.sketchybar # https://github.com/FelixKratz/SketchyBar
        pkgs.skhd       # https://github.com/koekeishiya/skhd
        pkgs.yabai      # https://github.com/koekeishiya/yabai

        pkgs.pngpaste   # https://github.com/jcsalterego/pngpaste

        pkgs.utm

        # I don't use this anymore.
        # pkgs.stats      # https://github.com/exelban/stats
      ]
      ++ [
        ###------------------------------
        ##   Extra Setup
        #--------------------------------
        pkgs.vscode-insiders   # Added from the overlay setup
      ];

    stateVersion = "23.11";
  };

  # Startup Processes
  launchd.agents = {
    ollama = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.ollama}/bin/ollama"
          "serve"
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
          # TODO: Correct the XDG directory reference
          "${pkgs.yabai}/bin/yabai"
          "-c"
          "/Users/${username}/.config/yabai/yabairc"
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
          # TODO: Correct the XDG directory reference
          "${pkgs.skhd}/bin/skhd"
          "-c"
          "/Users/${username}/.config/skhd/skhdrc"
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
    sketchybar = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.sketchybar}/bin/sketchybar"
          "-c"
          "/Users/${username}/.config/sketchybar/sketchybarrc.nu"
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
        # Although I would usually want to keep it runnig, there are cases where
        # I want to test updating some configurations. For that, it's best to
        # stop using Nix based version and run a local process instead.
        KeepAlive = false;
        RunAtLoad = true;
        WorkingDirectory  = "/tmp/";
        StandardOutPath   = "/tmp/sketchybar.log";
        StandardErrorPath = "/tmp/sketchybar.log";
      };
    };
  };

  xdg = {
    # NOTE: This contains only macOS specific settings.
    configFile = {
      "sketchybar".source = ../sketchybar;
      "sketchybar".recursive = true;

      "skhd/skhdrc".source   = ../skhdrc;
      "yabai/yabairc".source = ../yabairc;
    };
  };
}
