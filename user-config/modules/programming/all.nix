{ pkgs, ... }:
# Cross-language: applies regardless of language.
{
  home.packages = [
    pkgs.tree-sitter # https://github.com/tree-sitter/tree-sitter
  ];
}
