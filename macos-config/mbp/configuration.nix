{ config, pkgs, inputs, ... }:

let username = inputs.username;
in {
  nix = {
    configureBuildUsers = true;

    # Enable experimental Nix command and Flakes.
    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      extra-platforms = x86_64-darwin aarch64-darwin
    '';

    gc = {
      automatic = true;
      interval = { Hour = 24; };
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [ "@admin" ];

      substituters = [ "https://rytswd-nix-config.cachix.org" ];
      trusted-public-keys = [ "rytswd-nix-config.cachix.org-1:fpZQ465aGF2LYQ8oKOrd5c8kxaNmD7wBEK/yyhSQozo=" ];
    };
  };

  # Ensure Nix daemon is running.
  services = {
    nix-daemon.enable = true;
  };

  environment = {
    darwinConfig = "/Users/${username}/Coding/home/nix"; # TODO: Need to review this
    # Globally installed packages
    systemPackages = pkgs.lib.attrValues {
      inherit (pkgs)
        git
        jq
        comma
        nix-index
        cachix
        # Ensure that the latest zsh is available globally. This is to ensure
        # any app that needs to tie to a shell setup would be backed by Nix. An
        # example is Alacritty, where it needs to use the right shell version
        # specified in the config.
        zsh
      ;
    };
  };
    
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish; # TODO: This is not being picked up correctly.
  };

  fonts = {
    fontDir.enable = true;
    # Ref: https://nixos.wiki/wiki/Fonts
    fonts = [
      (pkgs.nerdfonts.override {
        fonts = [
          "FiraCode"
          "FiraMono"
          "Hack"
          "DroidSansMono"
          "Noto"
          "NerdFontsSymbolsOnly"
        ]; })
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
      "brave-browser"
      "google-chrome"
      "firefox"
      "microsoft-edge-dev"

      ###------------------------------
      ##   Input
      #--------------------------------
      "google-japanese-ime"

      ###------------------------------
      ##   Storage
      #--------------------------------
      # "google-drive"

      ###------------------------------
      ##   Music
      #--------------------------------
      "spotify"

      ###------------------------------
      ##   Utilities
      #--------------------------------
      "kap"
      "authy"
      "raycast"
      "docker"

      ###------------------------------
      ##   Other
      #--------------------------------
      "gather"
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
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 1;

        NSAutomaticCapitalizationEnabled = false;     # Disable automatic capitalization.
        NSAutomaticPeriodSubstitutionEnabled = false; # Disable double-space to add period.

        # TODO: Check whether these values are better managed at different level
        # than NSGlobalDomain.
        # AppleShowAllFiles = true; # Always show hidden files.

        "com.apple.keyboard.fnState" = true;        # Enable F1, F2, etc. as they are.
        "com.apple.sound.beep.volume" = 0.25;  # Set the beep volume to 25%.
        # "com.apple.mouse.tapBehavior" = 1; # Enable tap to click.
      };

      dock = {
        autohide = true;
        showhidden = true;
        show-recents = false;
        orientation = "bottom"; # NOTE: Updating this would require a restart.
        wvous-tl-corner = 10; # Put display to sleep.
        wvous-tr-corner = 1;  # Disabled.
        wvous-bl-corner = 13; # Lock screen.
        wvous-br-corner = 1;  # Disabled.
      };

      finder = {
        AppleShowAllFiles = true;       # Always show hidden files.
        AppleShowAllExtensions = true;  # Always show file extensions.
        QuitMenuItem = true;            # Enable "Quit Finder" menu item.
        ShowPathbar = true;             # Show path bar.

        FXEnableExtensionChangeWarning = false; # Disable warning when changing file extension.
        FXPreferredViewStyle = "Nlsv";  # List view by default.
      };

      trackpad.Clicking = true;

      # screencapture.location = "/Users/${username}/Google \Drive/My \Drive/Screenshots";

      # CustomUserPreferences = {
      #   "com.apple.HIToolbox" = {
      #     # Add Dvorak
      #     "com.apple.HIToolbox.AppleEnabledInputSources.0" = {
      #       "InputSourceKind" = "Keyboard Layout";
      #       "KeyboardLayout ID" = "16301";
      #       "KeyboardLayout Name" = "DVORAK - QWERTY CMD";
      #     };
      #     "com.apple.HIToolbox.AppleFnUsageType" = 2; # Use F1, F2 as standard function keys
      #   };
      # };
    };
  };
}
