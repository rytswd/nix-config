# Many coding dependencies are better handled per project / directory, but
# here are some common ones I would always want to keep in my PATH for
# convenience, or that existing tooling expects to find.
{
  imports = [
    ./all.nix
    ./c.nix
    ./css.nix
    ./go.nix
    ./haskell.nix
    ./html.nix
    ./java.nix
    ./javascript.nix
    ./lua.nix
    ./markdown.nix
    ./nix.nix
    ./protobuf.nix
    ./python.nix
    ./rust.nix
    ./toml.nix
    ./yaml.nix
    ./zig.nix
    # NOTE: ./roc.nix is intentionally NOT imported here — build is currently
    # broken. Import the leaf directly when I want to try.
  ];
}
