# macOS specific Home Manager configurations

{
  config,
  pkgs,
  inputs,
  self,
  ...
}:

let
  username = "ryota";
in
{
  imports = [
    # Shared machine-local values (`local.repoPath`, `local.availablePackages`).
    "${self}/user-config/modules/lib/paths.nix"
    "${self}/user-config/modules/lib/pkgs.nix"
    # Home-manager bootstrap (CLI install + release-check suppression).
    "${self}/user-config/modules/home-manager"

    # The shell setup defines some aliases, and in order to allow overriding,
    # calling this earlier than other modules.
    "${self}/user-config/modules/shell"

    # "${self}/user-config/modules/git-clone"  # TODO: module path does not exist; private?
    "${self}/user-config/modules/key-remap/skhd"
    "${self}/user-config/modules/window-manager/yabai"

    "${self}/user-config/modules/terminal"
    "${self}/user-config/modules/vcs"
    "${self}/user-config/modules/editor"
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/security"
    # Extra tooling for operating clusters (opt-in leaf).
    "${self}/user-config/modules/dictionary"
    "${self}/user-config/modules/communication"
    "${self}/user-config/modules/image"

    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/kubernetes/kubernetes-extra.nix"

    "${self}/user-config/modules/product/cloud"
    "${self}/user-config/modules/product/security"
    "${self}/user-config/modules/product/vcs"
    "${self}/user-config/modules/product/collaboration"
  ];

  home = {
    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages = [
      ###------------------------------
      # NOTE: Slack, Discord, Telegram, Zoom (and Signal, where it builds)
      # now come in via product/collaboration. They used to be listed
      # directly here.
      ###------------------------------
      ##   macOS Specific
      #--------------------------------
      pkgs.skhd # https://github.com/koekeishiya/skhd
      pkgs.yabai # https://github.com/koekeishiya/yabai

      pkgs.pngpaste # https://github.com/jcsalterego/pngpaste

      pkgs.utm

      # I don't use this anymore.
      # pkgs.stats      # https://github.com/exelban/stats
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
        WorkingDirectory = "/tmp/";
        StandardOutPath = "/tmp/yabai.log";
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
        WorkingDirectory = "/tmp/";
        StandardOutPath = "/tmp/skhd.log";
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
