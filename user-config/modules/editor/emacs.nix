{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.emacs.enable = lib.mkEnableOption "Enable Emacs.";
  };

  config = lib.mkIf config.editor.emacs.enable {
    # There is an overlay in place to configure how it's built. Actual Emacs
    # configurations are not managed in Nix, and is managed in a separate
    # repository as of writing. This is because I like the fast feedback loop
    # using Elpaca, and the packages installed here are those that need extra
    # steps configuring using Elpaca.
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-rytswd; # Based on overlay with extra build flags.
      extraPackages = (epkgs: with epkgs; [
        vterm
        jinx
        pdf-tools
        mu4e
        treesit-grammars.with-all-grammars
      ]);
    };
  };
}
