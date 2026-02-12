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
      # IMPORTANT: Include the mutable file that the YubiKey script writes to.
      # If the file is empty (no key), Git just ignores it.
      includes = [
        { path = "${config.xdg.configHome}/git/yubikey-status"; }
      ];

      settings = {
        user = {
          name = "Ryota";
          # NOTE: email is set separately.
          useConfigOnly = true;
          # REMOVED: signingkey (handled dynamically)
          # Key with YubiKey
          # signingkey = "0D952F25BB1123EA";
          # Old with 3 YubiKeys
          # signingkey = "0651ED8112A83CB5";
        };
        github.user = "rytswd";
        gitlab.user = "rytswd";
        credential.helper =  "${pkgs.gitFull}/bin/git-credential-libsecret";

        # Use ssh instead of https for git operations
        url."ssh://git@github.com/".insteadOf = "https://github.com/";

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

        help.autocorrect = "prompt";
        commit.gpgsign = true;
        format.signoff = true;

        # NOTE: A lot of the settings here aren't really used as I use Emacs's
        # magit for most of git interactions.
        push.default = "current";
        fetch.prune = true;
        pull.rebase = true;
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };

        # Taken from GitButler Bits and Booze video
        column.ui = "auto";
        branch.sort = "-committerdate";
        tag.sort = "version:refname";
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };

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
