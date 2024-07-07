{ pkgs
, lib
, config
, ...}:

{
  options = {
    terminal.ghostty.enable = lib.mkEnableOption "Enable Ghostty.";
  };

  config = lib.mkIf config.terminal.ghostty.enable {
    home.packages = [
      ###------------------------------
      ##   Ghostty
      #--------------------------------
      # Because it's managed in a private repository for now, adding this as a
      # separate entry.
      # NOTE: Ghostty cannot be built using Nix only for macOS, and thus this is
      # only built in NixOS.
      inputs.ghostty.packages.${system}.default
    ];

    configFile = {
      "ghostty/config".source = if pkgs.stdenv.isDarwin
                                then ./ghostty-for-macos.conf
                                else ./ghostty-for-nixos.conf;
    };
  };
}
