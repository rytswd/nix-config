{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = {
    boot.loader = {
      efi.canTouchEfiVariables = true;
    };
  };
}
