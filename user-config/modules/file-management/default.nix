{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./dropbox.nix
  ];

  file-management.dropbox.enable = lib.mkDefault true;
}
