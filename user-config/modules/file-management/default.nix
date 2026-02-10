{ pkgs
, lib
, config
, ...}:

{
  imports = [
    ./dropbox.nix
    ./syncthing.nix
  ];

  rytswd.file-management.dropbox.enable = lib.mkDefault true;
  rytswd.file-management.syncthing.enable = lib.mkDefault true;
}
