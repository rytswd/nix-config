{ pkgs, ... }:
{
  home.packages = [
    # gcloud wrapped with the GKE auth plugin component baked in.
    # Ref: https://github.com/NixOS/nixpkgs/issues/99280
    (with pkgs.google-cloud-sdk;
      withExtraComponents [ components.gke-gcloud-auth-plugin ]
    )
  ];

  home.shellAliases = {
    gccact = "gcloud config configurations activate";
    gccls  = "gcloud config configurations list";
  };
}
