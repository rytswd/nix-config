{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./sound.nix
    ./pipewire.nix
  ];

  media.sound.enable = lib.mkDefault true;
  media.pipewire.enable = lib.mkDefault true;
}
