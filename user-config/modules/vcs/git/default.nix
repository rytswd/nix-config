{
  pkgs,
  config,
  inputs,
  ...
}:
let
  allKeys = import "${inputs.self}/shared/keys.nix";
in
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    # NOTE: This isn't working as I have a config file directly copied.
    # extraConfig = {
    #   credential.helper = "libsecret";
    # };
  };
  home.packages = [
    pkgs.git-lfs # https://github.com/git-lfs/git-lfs
    pkgs.git-codereview # https://golang.org/x/review/git-codereview
    pkgs.git-crypt # https://github.com/AGWA/git-crypt
    pkgs.libsecret

    # TODO: It may be better to take out below, as I don't use it too much.
    pkgs.pre-commit
    pkgs.python314Packages.pre-commit-hooks
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

        # The GPG signing key is a constant shared by all four YubiKeys, so
        # it is baked in statically here and the mutable yubikey-status file
        # included above only *overrides* it for the SSH-signing fallback.
        #
        # WHY NOT leave this dynamic-only: git-signing-yubikey probes the card
        # (`gpg --card-status`) and truncates yubikey-status when the probe
        # fails, so it cannot tell "no YubiKey on this machine" apart from
        # "scdaemon could not reach the card for a moment". A stale pcscd --
        # the exact failure documented in security/gpg.nix -- made the udev
        # hook clear the file, which dropped user.signingkey entirely. git
        # then falls back to `$user.name <$user.email>` as the gpg -u selector
        # ("Ryota <rytswd@gmail.com>"), and since gpg substring-matches UIDs
        # that never matches the real "Ryota Sawada (with ECC) <...>" uid:
        # every commit failed with "No secret key" until the unit was re-run
        # by hand. Pinning the key id means a transient card hiccup surfaces
        # as a clear gpg error at signing time instead of silently
        # reconfiguring git.
        #
        # Costs nothing at runtime: this is an eval-time constant written
        # straight into the generated gitconfig, so the common path no longer
        # depends on a card round-trip having succeeded.
        signingkey = allKeys.gpg-key-id;
      };
      github.user = "rytswd";
      gitlab.user = "rytswd";
      credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";

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
}
