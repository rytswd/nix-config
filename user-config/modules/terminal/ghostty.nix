{ pkgs
, lib
, config
, inputs
, ...}:

{
  options = {
    terminal.ghostty.enable = lib.mkEnableOption "Enable Ghostty.";
  };

  config = lib.mkIf config.terminal.ghostty.enable {
    home.packages =
      if pkgs.stdenv.isDarwin
      then [
        # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
        # only built in NixOS.
      ]
      else [
        # pkgs.ghostty

        # NOTE: At times I hit the OpenGL context issue:
        # Ref: https://ghostty.org/docs/install/binary
        # This is based on the latest build.
        inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

    xdg.configFile = {
      "ghostty/config".source =
        if pkgs.stdenv.isDarwin
        then ./ghostty-for-macos.conf
        else ./ghostty-for-nixos.conf;
    };
  };
}
