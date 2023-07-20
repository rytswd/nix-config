{ pkgs, ... }:

{
    services.xserver = {
        enable = true;

        # Keyboard layout, dvorak as the main layout, and US as sub
        layout = "dvorak,us"; 

        dpi = 220;
        xkbOptions = "ctrl:nocaps"; # TODO: Check what this does

        desktopManager = {
            xterm.enable = false;
            # plasma5.enable = true;
            wallpaper.mode = "fill";
        };

        displayManager = {
            lightdm.enable = true;

            defaultSession = "none+i3";

            # AARCH64: For now, on Apple Silicon, we must manually set the
            # display resolution. This is a known issue with VMware Fusion.
            sessionCommands = ''
                ${pkgs.xlibs.xset}/bin/xset r rate 200 40
                ${pkgs.xorg.xrandr}/bin/xrandr -s '2880x1800'
            '';
        };

        windowManager = {
            # Main usage is based on i3, which is simple to start with.
            i3.enable = true;

            # qtile added just for testing.
            qtile.enable = true;

            # bspwm is a very minimalistic setup, which requires additional
            # softwares to work nicely. Because it is made simple, this may be
            # worth looking at in the future.
            bspwm.enable = true;

            # xmonad needs extra configs, and keeping it around just for reference.
            xmonad = {
                enable = true;
                enableContribAndExtras = true;
                extraPackages = hpkgs: [
                    hpkgs.xmonad
                    hpkgs.xmonad-contrib
                    hpkgs.xmonad-extras
                ];
            };

        };
    };

    services.greenclip.enable = true;
}
