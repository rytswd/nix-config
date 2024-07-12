{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.neovim.enable = lib.mkEnableOption "Enable NeoVim.";
  };

  config = lib.mkIf config.editor.neovim.enable {
    # NeoVim isn't my daily driver, but I use it time to time. The configuration
    # is now managed by NvChad, and thus nothing is configured here. I may
    # decide to manage everything here in Nix at some point, but it is not the
    # priority for now.
    programs.neovim = {
      enable = true;
    };
  };
}
