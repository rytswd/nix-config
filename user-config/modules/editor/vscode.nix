{ pkgs
, lib
, config
, ...}:

{
  options = {
    editor.vscode.enable = lib.mkEnableOption "Enable VSCode.";
  };

  config = lib.mkIf config.editor.vscode.enable {
    programs.vscode = {
      enable = true;
      # I'm not managing extensions via home-manager.
      # extensions = with pkgs.vscode-extensions; [
      # dracula-theme.theme-dracula
      # vscodevim.vim
      # yzhang.markdown-all-in-one
      # ];
    };
  };
}
