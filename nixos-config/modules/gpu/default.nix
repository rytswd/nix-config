{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./standard.nix
    ./nvidia.nix
  ];

  gpu.standard.enable = lib.mkDefault true;
  gpu.nvidia-offload.enable = lib.mkDefault true;
}
