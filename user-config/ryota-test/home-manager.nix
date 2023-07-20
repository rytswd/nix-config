{ config, pkgs, username, ... }:

{
  home = {
    stateVersion = "22.11";

    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages =
      # import(../../common-config/home-manager/packages.nix) { inherit pkgs; }
      # ++ (with pkgs; [
      #   fzf
      # ]);
      pkgs.lib.attrValues {
        inherit (pkgs)
          fzf
          exa
        ;
      };

    shellAliases =
      import ../../common-config/home-manager/aliases.nix //
      {
        # Any aliases defined here will override the defaults.
        ls = "exa";
        l = "exa -l";
        ll = "exa -lT";
        la = "exa -la";
        llt = "exa -laTF --git --group-directories-first --git-ignore --ignore-glob .git";
      };
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    bash.enable = true;
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      history.size = 10000;
      history.ignoreDups = true;
      history.ignoreSpace = true;
    };
    fish = {
      enable = true;
    };
    nushell = {
      enable = true;
    };
    starship = {
      enable = true;
    };
  };

  xdg.enable = true;
}
