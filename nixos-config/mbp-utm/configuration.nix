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

    # TODO: Check if this is necessary for UTM.
    # VMware, Parallels both only support this being 0 otherwise you see
    # "error switching console mode" on boot.
    loader.systemd-boot.consoleMode = "0";
  };

  hardware.opengl = {
    enable = true;
    # driSupport32Bit = true;
    # extraPackages = [ pkgs.virglrenderer ];
  };

  networking = {
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    hostName = "nixos-utm";
    # Disable the firewall since we're in a VM and we want to make it
    # easy to visit stuff in here. We only use NAT networking anyways.
    # firewall.enable = false;

    # TODO: Probably not needed.
    # Interface is this on M1
    interfaces.ens160.useDHCP = true;
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

  # TODO: Temporarily copying mitchellh's config directly. I should probably
  # tweak more.
  services.xserver = if linuxGnome then {
    enable = true;
    exportConfiguration = true;
    # System wide configuration, home-manager needs to be set up separately.
    layout = "us,us,jp";
    xkbVariant = "dvorak,,";
    xkbOptions = "ctrl:nocaps"; # Configure Caps Lock to be ctrl.
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  } else {
    enable = true;
    layout = "us,us,jp";
    xkbVariant = "dvorak,,";
    xkbOptions = "ctrl:nocaps"; # Configure Caps Lock to be ctrl.
    dpi = 220;

    desktopManager = {
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;

      # AARCH64: For now, on Apple Silicon, we must manually set the
      # display resolution. This is a known issue with VMware Fusion.
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset r rate 200 40
      '';
    };

    windowManager = {
      i3.enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      gnumake
      killall
      rxvt_unicode
      xclip

      git # NOTE: modified

      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      gtkmm3

      cachix # NOTE: added

      # For hypervisors that support auto-resizing, this script forces it.
      # I've noticed not everyone listens to the udev events so this is a hack.
      (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
    ];

    # For now, we need this since hardware acceleration does not work.
    variables.LIBGL_ALWAYS_SOFTWARE = "1";
  };

  programs = {
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

    spice-vdagentd.enable = true;

    # TODO: Clipboard stuff, not sure why it's here, will need to move to somewhere else.
    # greenclip.enable = true;
  };



  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
