{ config
, lib
, pkgs
, inputs
, ... }:

let username = "ryota"; # FIXME this is broken now.
in {
  nix = {
    configureBuildUsers = true;

    gc = {
      automatic = true;
      interval = { Hour = 23; };
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;

    settings = {
      max-jobs = 8;
      trusted-users = [ "@admin" ];

      # Recommended when using `direnv` etc.
      keep-derivations = true;
      keep-outputs = true;

      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://rytswd-nix-config.cachix.org"
        # "https://ghostty.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo="
        # "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="

        # Unused
        # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        # "emacs-osx.cachix.org-1:Q2++pOcNsiEjmDLufCzzdquwktG3fFDYzZrd8cEj5Aw="
      ];

      extra-platforms = lib.mkIf (pkgs.system == "aarch64-darwin") [ "x86_64-darwin" "aarch64-darwin" ];
    };
  };

  services = {
    # Ensure Nix daemon is running.
    nix-daemon = {
      enable = true;
      logFile = "/var/log/nix-daemon.log";
    };
  };

  environment = {
    darwinConfig = "/Users/${username}/Coding/home/nix"; # TODO: Need to review this
    # Globally installed packages
    systemPackages = pkgs.lib.attrValues {
      inherit (pkgs)
        ###------------------------------
        ##   System Tools
        #--------------------------------
        git
        jq
        # Ensure that the latest zsh is available globally. This is to ensure
        # any app that needs to tie to a shell setup would be backed by Nix. An
        # example is Alacritty, where it needs to use the right shell version
        # specified in the config.
        zsh

        ###------------------------------
        ##   Nix Related
        #--------------------------------
        comma
        nix-index
        cachix

        ###------------------------------
        ##   UI Tools
        #--------------------------------
        # karabiner-elements # Couldn't make it work, disabling
      ;
    };
  };
    
  fonts = {
    # Ref: https://nixos.wiki/wiki/Fonts
    packages = [
      (pkgs.nerdfonts.override {
        fonts = [
          "DroidSansMono"
          "FiraCode"
          "FiraMono"
          "Hack"
          "Iosevka"
          "NerdFontsSymbolsOnly"
          "Noto"
        ]; })
    ] ++ [
      pkgs.raleway
      pkgs.monaspace
    ];
  };

  programs = {
    # These shell settings are global configurations, meaning they would work on
    # files under /etc/ (and they would be stored in /etc/static/).
    #
    # NOTE: Upon the initial installation, the files such as /etc/bashrc, etc.
    # need to be moved so that Nix can create the new files.
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # NOTE: This means that Homebrew Casks are managed outside of Nix.
  homebrew = {
    enable = true;
    casks = [
      ###------------------------------
      ##   Browser
      #--------------------------------
      # A lot of the below aren't supported by Nix on macOS, and thus using
      # Homebrew instead.
      "arc"
      "chromium"
      "brave-browser"
      "google-chrome"
      "firefox"
      "vivaldi"
      # "microsoft-edge-dev"

      ###------------------------------
      ##   Input
      #--------------------------------
      "google-japanese-ime"

      ###------------------------------
      ##   Storage
      #--------------------------------
      "dropbox"
      # "google-drive"

      ###------------------------------
      ##   Music
      #--------------------------------
      "spotify"

      ###------------------------------
      ##   Video
      #--------------------------------
      "obs"
      "screen-studio"

      ###------------------------------
      ##   Utilities
      #--------------------------------
      "raycast"
      "kap"
      "docker"
      "orbstack"
      "keycastr"
      "protonvpn"
      "tailscale"

      ###------------------------------
      ##   Other
      #--------------------------------
      # "gather"
      "signal" # signal-desktop package on Nix doesn't work on macOS.
    ];
  };

  security = {
    # Allow use of TouchID for sudo authentication.
    pam.enableSudoTouchIdAuth = true;
  };

  # NOTE: For retrieving the existing setting, you can run the following:
  #
  #     defaults read NSGlobalDomain.
  #
  system = {
    # Currently, applications aren't linked to /Application.
    # https://github.com/LnL7/nix-darwin/issues/139#issuecomment-663117229
    build.applications = pkgs.lib.mkForce (pkgs.buildEnv {
      name = "applications";
      paths = config.environment.systemPackages
              ++ config.home-manager.users.${username}.home.packages;
      pathsToLink = "/Applications";
    });

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    defaults = {
      # Ref: https://github.com/LnL7/nix-darwin/tree/master/modules/system/defaults

      NSGlobalDomain = {
        InitialKeyRepeat    = 15;
        KeyRepeat           = 1;

        NSAutomaticCapitalizationEnabled        = false;    # Disable automatic capitalization.
        NSAutomaticPeriodSubstitutionEnabled    = false;    # Disable double-space to add period.

        "com.apple.keyboard.fnState"    = true; # Enable F1, F2, etc. as they are.
        "com.apple.sound.beep.volume"   = 0.25; # Set the beep volume to 25%.

        _HIHideMenuBar = true;  # Hide menu bar as I'm using more customisable menu bar.

        # NOTE: Below is only for reference. They are set by different config options.
        # AppleShowAllFiles = true; # Always show hidden files.
        # "com.apple.mouse.tapBehavior" = 1; # Enable tap to click.
      };

      # Ref: clock setting
      # https://github.com/LnL7/nix-darwin/blob/master/modules/system/defaults/clock.nix

      dock = {
        autohide        = true;
        showhidden      = true;
        show-recents    = false;
        orientation     = "bottom"; # NOTE: Updating this would require a restart.
        wvous-tl-corner = 10;       # Top Left:  Put display to sleep.
        wvous-tr-corner = 1;        # Top Right: Disabled.
        wvous-bl-corner = 13;       # Bottom Left:  Lock screen.
        wvous-br-corner = 1;        # Bottom Right: Disabled.
      };

      finder = {
        AppleShowAllFiles       = true; # Always show hidden files.
        AppleShowAllExtensions  = true; # Always show file extensions.
        QuitMenuItem            = true; # Enable "Quit Finder" menu item.
        ShowPathbar             = true; # Show path bar.

        FXEnableExtensionChangeWarning = false; # Disable warning when changing file extension.
        FXPreferredViewStyle    = "Nlsv";  # List view by default.
      };

      trackpad.Clicking = true;
    };
  };

  # The system version works differently for macOS.
  # Ref: https://github.com/LnL7/nix-darwin/issues/1087
  system.stateVersion = 4;
}
