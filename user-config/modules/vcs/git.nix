{ pkgs
, lib
, config
, ...}:

{
  options = {
    vcs.git.enable = lib.mkEnableOption "Enable Git related items.";
  };

  config = lib.mkIf config.vcs.git.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      # NOTE: This isn't working as I have a config file directly copied.
      # extraConfig = {
      #   credential.helper = "libsecret";
      # };
    };
    home.packages = [
      pkgs.git-lfs          # https://github.com/git-lfs/git-lfs
      pkgs.git-codereview   # https://golang.org/x/review/git-codereview
      pkgs.git-crypt        # https://github.com/AGWA/git-crypt
      pkgs.libsecret
    ];
    xdg.configFile = {
      "git".source = ./git;
      "git".recursive = true;
    };
  };
}
