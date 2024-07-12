{ pkgs
, lib
, config
, ...}:

{
  options = {
    vcs.git.enable = lib.mkEnableOption "Enable Git related items.";
  };

  config = lib.mkIf config.vcs.git.enable {
    home.packages = [
      pkgs.git-lfs          # https://github.com/git-lfs/git-lfs
      pkgs.git-codereview   # https://golang.org/x/review/git-codereview
      pkgs.git-crypt        # https://github.com/AGWA/git-crypt
    ];

    xdg.configFile = {
      "git".source = ./git;
      "git".recursive = true;
    };
  };
}
