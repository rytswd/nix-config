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
  programming.nix.enable = lib.mkDefault true;
  programming.go.enable = lib.mkDefault true;
  programming.rust.enable = lib.mkDefault true;
  programming.shell.enable = lib.mkDefault true;
  programming.html.enable = lib.mkDefault true;
  programming.css.enable = lib.mkDefault true;
  programming.javascript.enable = lib.mkDefault true;
  programming.python.enable = lib.mkDefault true;
  programming.zig.enable = lib.mkDefault true;
  programming.roc.enable = lib.mkDefault true;
  programming.markdown.enable = lib.mkDefault true;
  programming.c.enable = lib.mkDefault true;
  programming.protobuf.enable = lib.mkDefault true;
  programming.java.enable = lib.mkDefault true;
}
