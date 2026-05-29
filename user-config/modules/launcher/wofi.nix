# wofi — not imported by the launcher bundle's default.nix. Import this leaf
# directly from a host config if you actually want wofi.
{
  programs.wofi = {
    enable = true;
    # More config to be placed here.
    settings = {
      gtk_dark = true;
      insensitive = true;
      allow_images = true;
      image_size = 12;
      key_expand = "Tab";
    };
    style = (builtins.readFile ./wofi-styles.css);
  };
}
