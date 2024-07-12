{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming-language.protobuf.enable = lib.mkEnableOption "Enable Protobuf related tools.";
  };

  config = lib.mkIf config.programming-language.protobuf.enable {
    home.packages = [
      pkgs.buf
    ];
  };
}
