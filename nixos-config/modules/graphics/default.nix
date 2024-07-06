{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./standard.nix
    ./nvidia.nix
  ];

  graphics.standard.enable = lib.mkDefault true;
  graphics.nvidia-offload.enable = lib.mkDefault true;
}
