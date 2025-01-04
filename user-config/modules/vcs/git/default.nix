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
      # TODO: It may be better to take this out, as I don't use it too much.
      pkgs.pre-commit
      pkgs.python311Packages.pre-commit-hooks
    ];
    xdg.configFile = {
      # "git/config".source = ./git/config;
      "git/ignore".source = ./ignore;
    };

    # Git config equivalent
    programs.git = {
      extraConfig = {
        user = {
          name = "Ryota";
          # NOTE: email is set below with includes.
          useConfigOnly = true;
          # Key with YubiKey
          signingkey = "E0784F1CC9B94CFF";
          # Old RSA based
          # signingkey = "24F699F8056E6082";
          # Old key used on macOS
          # signingkey = 678FE5498813DE6A
        };
        github.user = "rytswd";
        gitlab.user = "rytswd";
        credential.helper =  "${pkgs.gitFull}/bin/git-credential-libsecret";

        core = {
          autocrlf = "input";
          editor = "nvim";
        };
        color = {
          branch = true;
          ui = true;
          diff = true;
          status = true;
        };

        init = {
          defaultBranch = "main";
          # templatedir = "${config.xdg.configHome}/git/templates";
        };

        help.autocorrect = 1;
        commit.gpgsign = true;

        # NOTE: A lot of the settings here aren't really used as I use Emacs's
        # magit for most of git interactions.
        push.default = "current";
        fetch.prune = true;
        pull.rebase = true;
        rebase.autoStash = true;

        filter.lfs = {
          required = true;
	      clean = "git-lfs clean -- %f";
	      smudge = "git-lfs smudge --skip -- %f";
	      process = "git-lfs filter-process --skip";
        };

        alias = {
	      s = "status";
	      c = "commit -am";
	      ci = "commit";
	      amend = "commit --amend";
	      co = "checkout";
	      ls = "branch -a";
	      lg = "log --oneline --decorate --graph";
	      lga = "log --oneline --all --decorate --graph";
	      rbi = "rebase --interactive";
	      rba = "rebase --abort";
	      forget = "update-index --assume-unchanged";
	      unforget = "update-index --no-assume-unchanged";
	      fp = "fetch --prune";
	      hide = "update-index --assume-unchanged";
	      unhide = "update-index --no-assume-unchanged";
	      unhide-all = "update-index --really-refresh";
	      hidden = "!git ls-files -v | grep \\\"^[a-z]\\\"";
	      ignored = "!git status -s --ignored | grep \\\"^!!\\\"";
        };
      };
    };
  };
}
