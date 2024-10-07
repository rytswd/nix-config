{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.zed.enable = lib.mkEnableOption "Enable Helix.";
  };

  config = lib.mkIf config.editor.zed.enable {
    # Pending on https://github.com/nix-community/home-manager/pull/5455
    # programs.zed-editor = {
    #   enable = true;
    # };

    home.packages = [
      pkgs.zed-editor
    ];
  };
}
