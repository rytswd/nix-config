{ pkgs, ... }:
{
  home.packages = [
    # https://typst.app/ -- the Typst compiler. Needed for the in-editor
    # compile / preview / watch commands (typst-ts-mode shells out to it).
    pkgs.typst

    # https://github.com/Myriad-Dreamin/tinymist -- the Typst language
    # server. lsp-mode's built-in `lsp-typst' client runs `tinymist', and
    # typst-ts-mode in the Emacs config only loads when it is on PATH.
    pkgs.tinymist
  ];
}
