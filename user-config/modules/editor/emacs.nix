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
      emacs-nixos-override-attrs = {
        withPgtk = true;
        withNativeCompilation = true;
        withSQLite3 = true;
        withTreeSitter = true;
        withWebP = true;
        withImageMagick = true;
        withXwidgets = true;
      };

      # Based on Nixpkgs
      emacs-29-nixos = pkgs.emacs29-pgtk.override emacs-nixos-override-attrs;
      # Based on emacs-overlay
      emacs-29-unstable-nixos = pkgs.emacs-unstable.override emacs-nixos-override-attrs;
      # Emacs 30 is not yet released, and thus pulled in using emacs-overlay and
      # emacs mirror source as a part of flake input.
      emacs-30-nixos = (pkgs.emacs-git.overrideAttrs (old: {
        version = "30.0-${inputs.emacs-30-src.shortRev}";
        src = inputs.emacs-30-src;
      })).override emacs-nixos-override-attrs;

      packages = (epkgs: with epkgs; [
        vterm
        jinx
        pdf-tools
        mu4e
        # all-the-icons # TODO: This still requires a manual "install".
        treesit-grammars.with-all-grammars
      ]);
      in {
        enable = true;
        package = if pkgs.stdenv.isDarwin
        then pkgs.emacs-29-macos-plus
        else emacs-30-nixos;
        extraPackages = packages;
      };
  };
}
