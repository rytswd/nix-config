{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  emacsPkgs = pkgs.extend inputs.emacs-overlay.overlays.default;
  emacsFromOverlay = inputs.emacs-overlay.${pkgs.stdenv.hostPlatform.system};
in
{
  # Actual Emacs configurations are not managed in Nix, and is managed in a
  # separate repository as of writing. This is because I like the fast
  # feedback loop using Elpaca, and the packages installed here are those that
  # need extra steps configuring using Elpaca.

  home.packages =
    let
      ###----------------------------------------
      ##   Elisp
      #------------------------------------------
      extraPackages = (
        epkgs: with epkgs; [
          vterm
          jinx
          pdf-tools
          mu4e
          eglot-booster
          # all-the-icons # TODO: This still requires a manual "install".

          # NOTE: I have my own treesitter grammars
          # treesit-grammars.with-all-grammars
          inputs.treesitter-grammars.packages.${pkgs.stdenv.hostPlatform.system}.emacs-treesit-grammars
        ]
      );
      withPackages = emacs: emacs.pkgs.withPackages extraPackages;

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
      withNixOSOverride = emacs: emacs.override emacs-nixos-override-attrs;
      withWrapper =
        emacs:
        pkgs.writeShellScriptBin "emacs-master" ''
          exec ${emacs}/bin/emacs "$@"
        '';

      # Emacs unstable refers to the latest tag available. This is often the
      # latest stable build.
      emacs-unstable-nixos = emacsPkgs.emacs-unstable-pgtk |> withNixOSOverride |> withPackages;
      # Emacs git refers to the latest master build, and thus could be flaky.
      emacs-master-nixos = emacsPkgs.emacs-git-pgtk |> withNixOSOverride |> withPackages |> withWrapper;

      ###----------------------------------------
      ##   For macOS
      #------------------------------------------
      # Bare Emacs 30 (Cocoa/NS) for macOS. Base is upstream-stable `emacs30`
      # from nixpkgs -- the 30.x release, NOT master. On top of it we layer
      # the curated emacs-plus patch set: this is the deliberate "in-between"
      # of the now-unmaintained Mac port and a full emacs-plus build -- plain
      # upstream plus only the patches I actually want, all owned here.
      #
      # No Elisp is bundled (Elpaca manages packages at runtime), so this is
      # just the editor binary.
      #
      # Patches are pinned to a homebrew-emacs-plus commit for
      # reproducibility -- bump `emacsPlusPatchRev` to pull newer revisions.
      # If a hash ever mismatches after a bump, replace it with the `got:`
      # value Nix prints.
      emacsPlusPatchRev = "714f6b0c443012281ad055947e2c96ae3761e0e1";
      emacsPlusPatch =
        path: hash:
        pkgs.fetchpatch {
          url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/${emacsPlusPatchRev}/patches/${path}";
          sha256 = hash;
        };
      emacs-30-macos =
        (pkgs.emacs30.override {
          withNativeCompilation = true;
          withNS = true;
          withSQLite3 = true;
          withTreeSitter = true;
          withWebP = true;
          withImageMagick = true;
        }).overrideAttrs
          (oldAttrs: {
            pname = "emacs-plus";
            # NOTE: `--with-xwidgets` (in-Emacs WebKit) was previously enabled
            # here alongside a manual `WebKit` buildInput pulled from
            # `darwin.apple_sdk_11_0.frameworks`. nixpkgs removed that API,
            # which is what broke this build. Modern nixpkgs supplies the SDK
            # automatically, but xwidgets on darwin still needs extra wiring,
            # so it's left off to keep the base build reliable. To re-enable,
            # append `configureFlags = (oldAttrs.configureFlags or []) ++
            # [ "--with-xwidgets" ];` and verify it builds.
            patches = (oldAttrs.patches or [ ]) ++ [
              # NOTE: emacs-28/no-frame-refocus-cocoa.patch removed -- the change
              # is already present in the nixpkgs emacs30 (30.2) source, so
              # re-applying it fails patchPhase with "Reversed (or previously
              # applied) patch detected" and aborts the build.
              # Fix OS window role so yabai can pick up Emacs (29 reuses 28's)
              (emacsPlusPatch "emacs-28/fix-window-role.patch"
                "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=")
              # Rounded, undecorated frame (also needs default-frame-alist tweak)
              (emacsPlusPatch "emacs-30/round-undecorated-frame.patch"
                "fesZ0H3LO6T2AiRV8ASozKxZBpvVzwLEcLDy6rctR6c=")
              # Track OS-level light/dark mode
              (emacsPlusPatch "emacs-28/system-appearance.patch"
                "oM6fXdXCWVcBnNrzXmF0ZMdp8j0pzkLE66WteeCutv8=")
            ];
          });
    in
    if pkgs.stdenv.isDarwin then
      # Bare Emacs 30 (Cocoa) -- Elisp managed at runtime via Elpaca.
      [ emacs-30-macos ]
    else
      [
        emacs-unstable-nixos
        emacs-master-nixos
      ]
      ++ [
        # For performance update with LSP
        pkgs.emacs-lsp-booster
      ];

  # Symlink .emacs.d to Coding directory
  home.activation.linkEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    EMACS_CONFIG="${config.home.homeDirectory}/Coding/github.com/rytswd/emacs-config/rytswd"
    if [ -d "$EMACS_CONFIG" ]; then
      $DRY_RUN_CMD rm -rf ${config.home.homeDirectory}/.config/emacs
      $DRY_RUN_CMD ln -sf "$EMACS_CONFIG" ${config.home.homeDirectory}/.config/emacs
    fi
  '';
  # NOTE: The below approach makes use of mkOutOfStoreSymlink utility, which
  # works by ensuring the symlink gets created without copying the files into
  # Nix store. However, this may be problematic during the initial machine
  # setup, where the target files are not available. The above approach makes
  # use of a simple shell script, which is more idiomatic for Home Manager
  # use cases.
  # home.file.".emacs.d".source = config.lib.file.mkOutOfStoreSymlink
  #   "${config.home.homeDirectory}/Coding/github.com/rytswd/emacs-config/rytswd";
}
