{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.protobuf.enable = lib.mkEnableOption "Enable Protobuf related tools.";
  };

  config = lib.mkIf config.programming.protobuf.enable {
    home.packages = [
      pkgs.buf
    ];
  };
}
