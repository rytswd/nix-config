{
  pkgs,
  inputs,
  ...
}:

let
  niri-unstable = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
in
{
  environment.systemPackages = [
    niri-unstable
  ];

  # NOTE: This can only be enabled once built with this stanza commented out.
  programs.niri = {
    enable = true;
    package = niri-unstable;
  };

  # Default to niri as the default session.
  services.displayManager.defaultSession = "niri";
}
