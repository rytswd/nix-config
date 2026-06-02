{
  imports = [
    # NOTE: ./flameshot.nix is intentionally NOT imported here -- limited Wayland
    # support, so it's opt-in per host. Import the leaf directly when needed.
    ./grim.nix
    ./swappy.nix
  ];
}
