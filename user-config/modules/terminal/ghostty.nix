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
        # Because it's managed in a private repository for now, this needs a
        # separate input.
        inputs.ghostty.packages.${pkgs.system}.default
      ];

    xdg.configFile = {
      "ghostty/config".source =
        if pkgs.stdenv.isDarwin
        then ./ghostty-for-macos.conf
        else ./ghostty-for-nixos.conf;
    };
  };
}
