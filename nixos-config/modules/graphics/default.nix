# Universal graphics stack (Mesa + OpenGL, brightness control). Hardware-
# specific GPU modules live under `../devices/` — e.g. `../devices/nvidia.nix`
# for hosts with an NVIDIA dGPU.
{
  imports = [
    ./standard.nix
  ];
}
