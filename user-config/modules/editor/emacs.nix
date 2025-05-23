{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    editor.emacs.enable = lib.mkEnableOption "Enable Emacs.";
  };

  config = lib.mkIf config.editor.emacs.enable {
    # Actual Emacs configurations are not managed in Nix, and is managed in a
    # separate repository as of writing. This is because I like the fast
    # feedback loop using Elpaca, and the packages installed here are those that
    # need extra steps configuring using Elpaca.
    programs.emacs = let
      ###----------------------------------------
      ##   For NixOS
      #------------------------------------------
      emacs-nixos-override-attrs = {
        withPgtk = true;
        withNativeCompilation = true;
        withSQLite3 = true;
        withTreeSitter = true;
        withWebP = true;
        # withImageMagick = true;
        # Ref: https://github.com/NixOS/nixpkgs/pull/344631
        # It looks like Emacs 30 is not compatible with the webkit2gtk.
        # withXwidgets = true;
      };

      # Based on Nixpkgs
      emacs-29-nixos = pkgs.emacs29-pgtk.override emacs-nixos-override-attrs;
      # Based on emacs-overlay
      emacs-29-unstable-nixos = pkgs.emacs-unstable.override emacs-nixos-override-attrs;

      emacs-30-nixos = (pkgs.emacs-git-pgtk.overrideAttrs (old: {
        version = "30.0-${inputs.emacs-mirror-30-src.shortRev}";
        src = inputs.emacs-mirror-30-src;
      })).override emacs-nixos-override-attrs;

      # Latest Emacs source
      emacs-latest-nixos = (pkgs.emacs-git-pgtk.overrideAttrs (old: {
        version = "31.0-${inputs.emacs-mirror-latest-src.shortRev}";
        src = inputs.emacs-mirror-latest-src;
      })).override emacs-nixos-override-attrs;

      ###----------------------------------------
      ##   For macOS
      #------------------------------------------
      inherited = {
        inherit (pkgs.darwin) sigtool;
        inherit (pkgs.darwin.apple_sdk_) llvmPackages_14;
        inherit (pkgs.darwin.apple_sdk_11_0.frameworks)
      Accelerate AppKit Carbon Cocoa GSS ImageCaptureCore ImageIO IOKit OSAKit
      Quartz QuartzCore UniformTypeIdentifiers WebKit;
      };
      emacs-30-plus = (pkgs.emacs30.override {
        withNativeCompilation = true;
        withNS = true;
        withSQLite3 = true;
        withTreeSitter = true;
        withWebP = true;
        withImageMagick = true;
      }).overrideAttrs (oldAttrs: {
        pname = "emacs-plus";
        configureFlags = (oldAttrs.configureFlags or []) ++ [
          "--with-xwidgets" # withXwidgets flag is somehow disabled for darwin.
        ];
        buildInputs = (oldAttrs.buildInputs or []) ++ [
          inherited.WebKit  # webkit is required for Emacs, and this adds Apple WebKit.
        ];
        patches = (oldAttrs.patches or []) ++ [
          # Don't raise another frame when closing a frame
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-frame-refocus-cocoa.patch";
            sha256 = "QLGplGoRpM4qgrIAJIbVJJsa4xj34axwT3LiWt++j/c=";
          })
          # Fix OS window role so that yabai can pick up Emacs
          (pkgs.fetchpatch {
            # Emacs 29 uses the same patch as 28
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
            sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
          })
          # Use poll instead of select to get file descriptors
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/poll.patch";
            sha256 = "jN9MlD8/ZrnLuP2/HUXXEVVd6A+aRZNYFdZF8ReJGfY=";
          })
          # Add setting to enable rounded window with no decoration (still
          # have to alter default-frame-alist)
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
            sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
          })
          # Make Emacs aware of OS-level light/dark mode
          # https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/system-appearance.patch";
            sha256 = "oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=";
          })
        ];
      });

      packages = (epkgs: with epkgs; [
        vterm
        jinx
        pdf-tools
        mu4e
        lsp-bridge
        # all-the-icons # TODO: This still requires a manual "install".
        treesit-grammars.with-all-grammars
      ]);
    in {
      enable = true;
      package =
        if pkgs.stdenv.isDarwin
        then emacs-30-plus
        else
            # emacs-latest-nixos # latest uses the master branch
            emacs-30-nixos
      ;
      extraPackages = packages;
    };

    # For performance update with LSP
    home.packages = [ pkgs.emacs-lsp-booster ];
  };
}
