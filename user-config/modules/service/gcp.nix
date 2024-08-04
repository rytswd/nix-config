{ pkgs
, lib
, config
, ...}:

{
  options = {
    service.gcp.enable = lib.mkEnableOption "Enable GCP related tooling.";
  };

  config = lib.mkIf config.service.gcp.enable {
    home.packages = [
      # Ref: https://github.com/NixOS/nixpkgs/issues/99280
      (with pkgs.google-cloud-sdk;
        withExtraComponents ([ components.gke-gcloud-auth-plugin ])
      )
    ];
    home.shellAliases = {
      gccact = "gcloud config configurations activate";
      gccls = "gcloud config configurations list";
    };
  };
}
