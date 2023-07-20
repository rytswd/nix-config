{ config, pkgs, currentSystem, lib, ... }:

{
    imports = [
        # ./b.nix
    ];

    # use unstable nix so we can access flakes
    nix = {
        package = pkgs.nixUnstable;
        extraOptions = ''
            experimental-features = nix-command flakes
        '';
    };

    # We expect to run the VM on hidpi machines.
    hardware.video.hidpi.enable = true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;

    # Ensure password can be changed with `passwd`.
    users.mutableUsers = false;

    environment.systemPackages = with pkgs; [
        gnumake
        killall
        niv
        rxvt_unicode
        xclip

        # This is needed for the vmware user tools clipboard to work.
        # You can test if you don't need this by deleting this and seeing
        # if the clipboard sill works.
        gtkmm3

        # VMware on M1 doesn't support automatic resizing yet and on
        # my big monitor it doesn't detect the resolution either so we just
        # manualy create the resolution and switch to it with this script.
        # This script could be better but its hopefully temporary so just force it.
        (writeShellScriptBin "xrandr-6k" ''
            xrandr --newmode "6016x3384_60.00"  1768.50  6016 6544 7216 8416  3384 3387 3392 3503 -hsync +vsync
            xrandr --addmode Virtual-1 6016x3384_60.00
            xrandr -s 6016x3384_60.00
        '')
        (writeShellScriptBin "xrandr-mbp" ''
            xrandr -s 2880x1800
        '')
    ];

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = true;
    # services.openssh.permitRootLogin = "no";
    services.openssh.permitRootLogin = "yes"; # As I'm still testing, this makes it easier.

    # # Disable the firewall since we're in a VM and we want to make it
    # # easy to visit stuff in here. We only use NAT networking anyways.
    # networking.firewall.enable = false;

    # Disable the default module and import our override. We have
    # customizations to make this work on aarch64.
    disabledModules = [ "virtualisation/vmware-guest.nix" ];

    # An earlier kernel is required for VMware Fusion due to booting issues.
    # This will prob be fixed in the next update.
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

    # Interface is this on M1
    networking.interfaces.ens160.useDHCP = true;

}
