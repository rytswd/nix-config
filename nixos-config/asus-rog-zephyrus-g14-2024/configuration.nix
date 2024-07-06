# A lot of configurations have been taken / inspired by:
# https://github.com/mitchellh/nixos-config/blob/main/machines/vm-shared.nix

{ config
, pkgs
, currentSystem
, lib
, ... }:

{
  imports = [
    ../modules/core
    ../modules/graphics
    ../modules/media
    ../modules/devices
    ../modules/window-manager
    ../modules/login-manager
    ../modules/flatpak
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Be careful updating this.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "asus-rog-zephyrus-g14-2024";

  services.xserver = {
    enable = true;
    exportConfiguration = true;
    videoDrivers = ["nvidia"];
    # System wide configuration, which would be overridden by user specified
    # configuration. In order to persist with the relevant keyboard layouts,
    # separate home-manager setup needs to be in place.
    xkb = {
      layout = "us,us,jp";
      variant = "dvorak,,";
      options = "ctrl:nocaps"; # Configure Caps Lock to be ctrl.
    };
    desktopManager.gnome.enable = true;
    desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
    # desktopManager.gnome.extraGSettingsOverrides = ''
    #   [org.gnome.desktop.input-sources]
    #   sources=[('xkb', 'us+dvorak'), ('xkb', 'us'), ('xkb', 'jp')]
    # '';
    # displayManager.gdm.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      killall
      # xclip # With wl-clipboard, I shouldn't need this.

      cachix # NOTE: added

      # NOTE: I don't seem to need this.
      # gtkmm3

      # For debugging input
      wev
    ];

    # NOTE: Commenting out as this came from UTM setup originally.
    # # For now, we need this since hardware acceleration does not work.
    # variables.LIBGL_ALWAYS_SOFTWARE = "1";
  };

  programs = {
    # Ensure dconf is taken into account from NixOS startup.
    dconf.enable = true;
    dconf.profiles.user.databases = with lib.gvariant; [
      {
        settings = {
          # "com/raggesilver/BlackBox" = {
          #   opacity = mkUint32 100;
          #   theme-dark = "Tommorow Night";
          #   scrollback-lines = mkUint32 10000;
          # };
          "org/gnome/desktop/input-sources" = {
            mru-sources = [
              (mkTuple [ "xkb" "us+dvorak" ])
              (mkTuple [ "xkb" "us" ])
              (mkTuple [ "xkb" "jp" ])
            ];
            sources = [
              (mkTuple [ "xkb" "us+dvorak" ])
              # (mkTuple [ "xkb" "us" ])
              (mkTuple [ "xkb" "jp" ])
            ];
            xkb-options = [ "terminate:ctrl_alt_bksp" ];
          };
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };
        # locks = [
        #   "/com/raggesilver/BlackBox/theme-dark"
        # ];
      }
    ];

    # TODO: Check if this is necessary.
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
