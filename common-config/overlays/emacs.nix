final: prev:

# Ref:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/emacs/make-emacs.nix

let
  # Not all the dependencies below are used. This definition comes from the
  # upstream default.nix of Emacs.
  inherited = {
    inherit (prev.darwin) sigtool;
    inherit (prev.darwin.apple_sdk_11_0) llvmPackages_14;
    inherit (prev.darwin.apple_sdk_11_0.frameworks)
      Accelerate AppKit Carbon Cocoa GSS ImageCaptureCore ImageIO IOKit OSAKit
      Quartz QuartzCore UniformTypeIdentifiers WebKit;
  };

  ###----------------------------------------
  ##   Emacs Macport
  #------------------------------------------
  emacs-macport-base = prev.emacs29-macport.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
    withImageMagick = true;
  };
  emacs-macport-rytswd = emacs-macport-base.overrideAttrs (oldAttrs: {
    pname = "emacs-macport";
    configureFlags = (oldAttrs.configureFlags or []) ++ [
      "--with-xwidgets" # withXwidgets flag is somehow disabled for macport upstream.
    ];
    patches = (oldAttrs.patches or []) ++ [
      # NOTE: This is not working correctly for the natural menubar.
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/railwaycat/homebrew-emacsmacport/911412ca8ea2671c1122bc307a1cd0740005a55d/patches/emacs-mac-title-bar-9.1.patch";
        sha256 = "sha256-+SGySdRPFuw+yOuTwGiH4tLYqk4bh+2BRT46jUGEfuY=";
      })
    ];
  });

  ###----------------------------------------
  ##   Emacs Plus
  #------------------------------------------
  emacs-plus-base = prev.emacs29.override {
    withNativeCompilation = true;
    withNS = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
    withImageMagick = true;
  };
  emacs-plus-rytswd = emacs-plus-base.overrideAttrs (oldAttrs: {
    pname = "emacs-plus";
    configureFlags = (oldAttrs.configureFlags or []) ++ [
      "--with-xwidgets" # withXwidgets flag is somehow disabled for darwin.
    ];
    buildInputs = (oldAttrs.buildInputs or []) ++ [
      inherited.WebKit  # webkit is required for Emacs, and this adds Apple WebKit.
    ];
    # Special thanks to @noctuid:
    # Ref: https://github.com/noctuid/dotfiles/blob/master/nix/overlays/emacs.nix#L23
    patches = (oldAttrs.patches or []) ++ [
      # Don't raise another frame when closing a frame
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-frame-refocus-cocoa.patch";
        sha256 = "QLGplGoRpM4qgrIAJIbVJJsa4xj34axwT3LiWt++j/c=";
      })
      # Fix OS window role so that yabai can pick up Emacs
      (prev.fetchpatch {
        # Emacs 29 uses the same patch as 28
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
        sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
      })
      # Use poll instead of select to get file descriptors
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
        sha256 = "jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
      })
      # Add setting to enable rounded window with no decoration (still
      # have to alter default-frame-alist)
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
        sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
      })
      # Make Emacs aware of OS-level light/dark mode
      # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
      (prev.fetchpatch {
        url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
        sha256 = "oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
      })
    ];
  });

  ###----------------------------------------
  ##   Emacs Pure GTK
  #------------------------------------------
  emacs-pgtk-base = prev.emacs29-pgtk.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
    withImageMagick = true;
    withXwidgets = true;
  };
  emacs-pgtk-rytswd = emacs-pgtk-base.overrideAttrs (oldAttrs: {
    # pname = "emacs-rytswd";
  });

  ###----------------------------------------
  ##   Emacs GTK3
  #------------------------------------------
  emacs-gtk3-base = prev.emacs29-gtk3.override {
    withNativeCompilation = true;
    withSQLite3 = true;
    withTreeSitter = true;
    withWebP = true;
    withImageMagick = true;
    withXwidgets = true;
  };
  emacs-gtk3-rytswd = emacs-gtk3-base.overrideAttrs (oldAttrs: {
    # pname = "emacs-rytswd";
  });

  ###----------------------------------------
  ##   Main Setup
  #------------------------------------------
  # I could replace "emacs" but keeping it explicitly separate for now.
  emacs-rytswd = if prev.stdenv.isDarwin
                 then emacs-plus-rytswd
                 else emacs-pgtk-rytswd;

  ###----------------------------------------
  ##   Packages
  #------------------------------------------
  # When building with extra packages, this makes double wrapping and causes
  # undesirable side effects when using home-manager's programs.emacs. When
  # using the package directly, these can be helpful, but these are only meant
  # to be references and not used in my configuration.
  packages = (epkgs: with epkgs; [
    vterm
    jinx
    pdf-tools
    mu4e
    treesit-grammars.with-all-grammars
  ]);
  emacs-macport-rytswd-with-packages = emacs-macport-rytswd.pkgs.withPackages (packages);
  emacs-plus-rytswd-with-packages = emacs-plus-rytswd.pkgs.withPackages (packages);
  emacs-pgtk-rytswd-with-packages = emacs-pgtk-rytswd.pkgs.withPackages (packages);
  emacs-gtk3-rytswd-with-packages = emacs-gtk3-rytswd.pkgs.withPackages (packages);

in {
  emacs-rytswd = emacs-rytswd;

  emacs-macport-rytswd = emacs-macport-rytswd;
  emacs-plus-rytswd = emacs-plus-rytswd;
  emacs-pgtk-rytswd = emacs-pgtk-rytswd;
  emacs-gtk3-rytswd = emacs-gtk3-rytswd;
}
