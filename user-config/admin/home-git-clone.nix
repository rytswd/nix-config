{
  home.gitClone = {
    "Coding/github.com/rytswd/nix-config" = {
      url = "https://github.com:rytswd/nix-config.git";
      rev = "main";
      # useWorktree = false;  # Default: clone to Coding/.../emacs-config/
      update = true;          # Pull updates on each activation
    };
    # "Coding/github.com/rytswd/emacs-config" = {
    #   url = "https://github.com:rytswd/emacs-config.git";
    #   rev = "main";
    #   # useWorktree = false;  # Default: clone to Coding/.../emacs-config/
    #   # update = false;       # Set to true to pull updates on each activation
    # };
  };
}
