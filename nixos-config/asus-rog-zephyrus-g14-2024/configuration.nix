# A lot of configurations have been taken / inspired by:
# https://github.com/mitchellh/nixos-config/blob/main/machines/vm-shared.nix

{ config
, pkgs
, currentSystem
, lib
, ... }:

let linuxGnome = true; in {
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Be careful updating this.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # extraPackages = [ pkgs.virglrenderer ];
  };

  # Ref https://nixos.wiki/wiki/Nvidia
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  networking = {
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    hostName = "rytswd-nixos-asus-zephyrus-g14";
    # Disable the firewall since we're in a VM and we want to make it
    # easy to visit stuff in here. We only use NAT networking anyways.
    # firewall.enable = false;

    # TODO: Probably not needed.
    # Interface is this on M1
    # interfaces.ens160.useDHCP = true;
  };

  # Ensure password can be changed with `passwd`.
  users.mutableUsers = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
  virtualisation.docker.enable = true;

  # Select internationalisation properties.
  i18n = {
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
    };
  };

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
    displayManager.gdm.enable = true;
  };

  # Disable the touchpad while typing.
  # TODO: Check if this is actually working, and move this somewhere more sensible
  services.libinput.touchpad.disableWhileTyping = true;

  # For bluetooth manager GUI
  services.blueman.enable = true;

  environment = {
    systemPackages = with pkgs; [
      gnumake
      killall
      rxvt_unicode
      xclip

      git # NOTE: modified
      cachix # NOTE: added

      # NOTE: I don't seem to need this.
      # gtkmm3

      # NOTE: Copied from UTM setup, which shouldn't be necessary.
      # # For hypervisors that support auto-resizing, this script forces it.
      # # I've noticed not everyone listens to the udev events so this is a hack.
      # (writeShellScriptBin "xrandr-auto" ''
      #   xrandr --output Virtual-1 --auto
      # '')
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
    hyprland.enable = true;

    # These shell settings are global configurations, meaning they would work on
    # files under /etc/ (and they would be stored in /etc/static/).
    #
    # NOTE: Upon the initial installation, the files such as /etc/bashrc, etc.
    # need to be moved so that Nix can create the new files.
    # bash.enable = true; # NOTE: This has no effect and needs to be taken out.
    fish.enable = true;
    zsh.enable = true;

    # TODO: Check if this is necessary.
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
    openssh.settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes"; # As I'm still testing, this makes it easier.
    };

    # SPICE agent needed for screen resize handling, clipboard, etc.
    # Ref: https://docs.getutm.app/guest-support/linux/#spice-agent
    spice-vdagentd.enable = true;

    # WebDav for sharing the host's directory in UTM guest machine.
    # Ref: https://docs.getutm.app/guest-support/linux/#spice-webdav
    spice-webdavd.enable = true;
    # Ref: https://www.reddit.com/r/NixOS/comments/b5p6f7/how_do_i_use_davfs2/
    davfs2.enable = true;
    autofs = {
      enable = true;
      # Clear code inspired by:
      # https://github.com/GaetanLepage/dotfiles/blob/7855d6e3f082cbdb1a20142a8299cb33729366ab/nixos/tuxedo/autofs.nix#L16
      autoMaster = let mapConf = pkgs.writeText "autofs.mnt" ''
        mbp-coding \
            -fstype=davfs,uid=1000,file_mode=666,dir_mode=777,rw \
            :http\://localhost\:9843/Coding
        mbp-documents \
            -fstype=davfs,uid=1000,file_mode=666,dir_mode=777,rw \
            :http\://localhost\:9843/Documents
        '';
      in ''
        /utm-host   ${mapConf}  --timeout 600
      '';
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
