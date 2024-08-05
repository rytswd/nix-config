{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./obs.nix
  ];

  video.obs.enable = lib.mkDefault true;
}
