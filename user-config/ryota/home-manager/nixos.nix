# NixOS specific Home Manager configurations

{ pkgs
, ghostty
, ... }:

let username = "ryota";
in {
  imports = [
    ./common.nix
    ./dconf.nix # For GNOME
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    packages = [
      ###------------------------------
      ##   Ghostty
      #--------------------------------
      # Because it's managed in a private repository for now, adding this as a
      # separate entry.
      # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
      # only built in NixOS.
      ghostty.packages.aarch64-linux.default
    ];

    stateVersion = "23.11";
  };
}
