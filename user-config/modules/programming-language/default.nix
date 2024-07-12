{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./nix.nix
    ./go.nix
    ./rust.nix
    ./shell.nix
    ./html.nix
    ./css.nix
    ./javascript.nix
    ./python.nix
    ./zig.nix
    ./roc.nix
    ./markdown.nix
    ./c.nix
    ./protobuf.nix
    ./java.nix
  ];

  # Many coding dependencies are better handled per project / directory,
  # but here are some common ones I would always want to keep in my PATH
  # for convenience, or I need to have in PATH due to existing setup
  # expect such tools to be available.
  programming-language.nix.enable = lib.mkDefault true;
  programming-language.go.enable = lib.mkDefault true;
  programming-language.rust.enable = lib.mkDefault true;
  programming-language.shell.enable = lib.mkDefault true;
  programming-language.html.enable = lib.mkDefault true;
  programming-language.css.enable = lib.mkDefault true;
  programming-language.javascript.enable = lib.mkDefault true;
  programming-language.python.enable = lib.mkDefault true;
  programming-language.zig.enable = lib.mkDefault true;
  programming-language.roc.enable = lib.mkDefault true;
  programming-language.markdown.enable = lib.mkDefault true;
  programming-language.c.enable = lib.mkDefault true;
  programming-language.protobuf.enable = lib.mkDefault true;
  programming-language.java.enable = lib.mkDefault true;
}
