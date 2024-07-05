{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./pipewire.nix
  ];

  media.pipewire.enable = lib.mkDefault true;
}
