{ inputs, ... }:

{
  imports = [ inputs.home-git-clone.homeManagerModules.default ];

  ###----------------------------------------
  ##   Key Repositories
  #------------------------------------------
  home.gitClone = {
    "Coding/github.com/rytswd/nix-config".url = "git@github.com:rytswd/nix-config.git";
    "Coding/github.com/rytswd/nix-config-private".url = "git@github.com:rytswd/nix-config-private.git";
    "Coding/github.com/rytswd/emacs-config".url = "git@github.com:rytswd/emacs-config.git";
  };

  ###----------------------------------------
  ##   Active Projects
  #------------------------------------------
  home.jjClone = {
  };

  ###----------------------------------------
  ##   Active Personal Projects
  #------------------------------------------
  home.gitClone = {
    # NOTE: These can move to jj once workmux supports jj workspaces.
    "Coding/github.com/rytswd/skills.nix".url = "git@github.com:rytswd/skills.nix.git";
  };
  home.jjClone = {
    "Coding/github.com/rytswd/home-git-clone".url = "git@github.com:rytswd/home-git-clone.git";
    "Coding/github.com/rytswd/pi-agent-extensions".url = "git@github.com:rytswd/pi-agent-extensions.git";
    "Coding/github.com/rytswd/ren".url = "git@github.com:rytswd/ren.git";
    "Coding/github.com/rytswd/swapdir".url = "git@github.com:rytswd/swapdir.git";
  };

  ###----------------------------------------
  ##   Kubernetes
  #------------------------------------------
  home.gitClone = {
    "Coding/github.com/rytswd/sig-release".url = "git@github.com:rytswd/sig-release.git";
    "Coding/github.com/rytswd/k8s.io".url = "git@github.com:rytswd/k8s.io.git";
    "Coding/github.com/rytswd/k8s-enhancements".url = "git@github.com:rytswd/k8s-enhancements.git";
    "Coding/github.com/rytswd/k8s-org".url = "git@github.com:rytswd/k8s-org.git";
    "Coding/github.com/rytswd/k8s-website".url = "git@github.com:rytswd/k8s-website.git";
  };

}
