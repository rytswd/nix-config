{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.terraform.enable = lib.mkEnableOption "Enable Terraform related tools.";
  };

  config = lib.mkIf config.service.terraform.enable {
    home.packages = [
      pkgs.terraform
    ];
  };
}
