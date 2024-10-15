{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.haskell.enable = lib.mkEnableOption "Enable Haskell development related tools.";
  };

  config = lib.mkIf config.programming.haskell.enable {
    home.packages = [
      # A lot of references are from:
      # https://github.com/JonathanReeve/dotfiles/blob/master/dotfiles/configuration.nix
      (pkgs.haskellPackages.ghcWithPackages (ps: with ps; [
        # pandoc-citeproc
        shake         # Build tool
        hlint         # Required for spacemacs haskell-mode
        apply-refact  # Required for spacemacs haskell-mode
        hasktags      # Required for spacemacs haskell-mode
        hoogle        # Required for spacemacs haskell-mode
        lucid
        # stylish-haskell # Required for spacemacs haskell-mode
        # ^ marked as broken
        turtle        # Scripting
        regex-compat
        #PyF
        HandsomeSoup
        tokenize
        # chatter
      ]))
    ];
  };
}
