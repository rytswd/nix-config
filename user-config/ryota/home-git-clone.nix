{ inputs, ... }:

{
  imports = [ inputs.home-git-clone.homeManagerModules.default ];

  home.gitClone = {
    "Coding/github.com/rytswd/nix-config".url = "git@github.com:rytswd/nix-config.git";
    "Coding/github.com/rytswd/emacs-config".url = "git@github.com:rytswd/emacs-config.git";
  };

  home.jjClone = {
    "Coding/github.com/rytswd/ren".url = "git@github.com:rytswd/ren.git";
  };
}
