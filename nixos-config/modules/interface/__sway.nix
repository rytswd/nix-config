# Not used, only for record.

{ pkgs, ... }:

{
    # services.xserver = {
    #     enable = true;
    #     layout = "us";
    #     dpi = 220;
    #     xkbOptions = "ctrl:nocaps";
    #     libinput.enable = true; # Enable touchpad support

    #     desktopManager = {
    #         xterm.enable = false;
    #         plasma5.enable = true;
    #         wallpaper.mode = "fill";
    #     };

    #     displayManager = {
    #         gdm.enable = true;
    #         gdm.wayland = false;

    #         # lightdm.enable = true;

    #         # defaultSession = "none+i3";
    #         defaultSession = "none+qtile";

    #         # AARCH64: For now, on Apple Silicon, we must manually set the
    #         # display resolution. This is a known issue with VMware Fusion.
    #         sessionCommands = ''
    #             ${pkgs.xlibs.xset}/bin/xset r rate 200 40
    #             ${pkgs.xorg.xrandr}/bin/xrandr -s '2880x1800'
    #         '';
    #     };

    #     windowManager = {
    #         i3 = {
    #             enable = true;
    #             # package = pkgs.i3-gaps;
    #             extraPackages = with pkgs; [
    #                 dmenu # application launcher most people use
    #                 i3status # gives you the default i3 status bar
    #                 i3lock # default i3 screen locker
    #                 i3blocks #if you are planning on using i3blocks over i3status
    #             ];
    #         };

    #         qtile.enable = true;

    #         xmonad = {
    #             enable = true;
    #             enableContribAndExtras = true;
    #             extraPackages = hpkgs: [
    #                 hpkgs.xmonad
    #                 hpkgs.xmonad-contrib
    #                 hpkgs.xmonad-extras
    #             ];
    #         };
    #     };
    # };

    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true; # so that gtk works properly
        extraPackages = with pkgs; [
            swaylock
            swayidle
            wl-clipboard
            wf-recorder
            mako # notification daemon
            grim
            #kanshi
            slurp
            alacritty # Alacritty is the default terminal in the config
            dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
        ];
        extraSessionCommands = ''
            export SDL_VIDEODRIVER=wayland
            export QT_QPA_PLATFORM=wayland
            export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
            export _JAVA_AWT_WM_NONREPARENTING=1
            export MOZ_ENABLE_WAYLAND=1
        '';
    };
}
