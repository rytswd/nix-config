{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./obs.nix
    ./wf-recorder.nix
  ];

  video.obs.enable = lib.mkDefault true;
  video.wf-recorder.enable = lib.mkDefault true;
}
