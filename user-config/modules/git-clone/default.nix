{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.home.gitClone;

  # Empty git config file for bypassing user's git config
  emptyGitConfig = pkgs.writeText "empty-git-config" "";

  repoModule = types.submodule {
    options = {
      url = mkOption {
        type = types.str;
        description = "Git repository URL (HTTPS or SSH)";
        example = "git@github.com:rytswd/nix-config.git";
      };

      rev = mkOption {
        type = types.str;
        default = "main";
        description = "Branch or revision to checkout";
        example = "main";
      };

      useWorktree = mkOption {
        type = types.bool;
        default = false;
        description = ''
          If true, appends the rev/branch name to the path for worktree setup.
          Example: "Coding/repo" with rev="main" becomes "Coding/repo/main/"
          This allows easy use of `git worktree add` for sibling branches.
        '';
      };

      vcs = mkOption {
        type = types.enum [ "git" "jj" ];
        default = "git";
        description = "Version control system to use (git or jj)";
      };

      bypassGitConfig = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          If true, ignores git config during clone (useful to prevent HTTPS→SSH rewrites).
          If null (default), automatically bypasses config for HTTPS URLs only.
          If false, always uses git config.
        '';
      };

      update = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to pull updates on activation";
      };
    };
  };

  # Generate activation script for a single repository
  cloneRepoScript = path: repo:
    let
      # Sanitize the name for use in activation script
      name = builtins.replaceStrings ["/"] ["-"] path;
      # If useWorktree is true, append the rev to the path
      finalPath = if repo.useWorktree
                  then "${path}/${repo.rev}"
                  else path;
      repoPath = "${config.home.homeDirectory}/${finalPath}";

      # Commands based on VCS choice
      vcsCmd = if repo.vcs == "jj" then pkgs.jujutsu else pkgs.git;
      vcsName = repo.vcs;

      # Determine whether to bypass git config
      # - If bypassGitConfig explicitly set, use that
      # - Otherwise, auto-bypass for HTTPS URLs to prevent rewrites
      isHttps = lib.hasPrefix "https://" repo.url;
      shouldBypass = if repo.bypassGitConfig != null
                     then repo.bypassGitConfig
                     else isHttps;

      cloneCmd = if repo.vcs == "jj"
        then ''${vcsCmd}/bin/jj git clone "${repo.url}" "$REPO_PATH" --colocate --branch "${repo.rev}"''
        else if shouldBypass
          then ''${pkgs.coreutils}/bin/env GIT_CONFIG_GLOBAL=${emptyGitConfig} GIT_CONFIG_SYSTEM=${emptyGitConfig} ${vcsCmd}/bin/git clone --branch "${repo.rev}" "${repo.url}" "$REPO_PATH"''
          else ''${vcsCmd}/bin/git clone --branch "${repo.rev}" "${repo.url}" "$REPO_PATH"'';

      updateCmd = if repo.vcs == "jj"
        then ''${vcsCmd}/bin/jj -R "$REPO_PATH" git fetch && ${vcsCmd}/bin/jj -R "$REPO_PATH" rebase''
        else ''${vcsCmd}/bin/git -C "$REPO_PATH" pull'';

      checkDir = if repo.vcs == "jj" then ".jj" else ".git";
    in
    nameValuePair "vcs-clone-${name}" (hm.dag.entryAfter ["writeBoundary" "reloadSystemd"] ''
      # Only run git clone if we're actually the target user
      # This prevents ryota's activation from trying to clone admin's repos with ryota's creds
      CURRENT_USER=$(${pkgs.coreutils}/bin/whoami)
      if [ "$CURRENT_USER" != "${config.home.username}" ]; then
        echo "Skipping git-clone for ${config.home.username} (running as $CURRENT_USER)"
        exit 0
      fi

      # Ensure we have the tools we need
      export PATH="${pkgs.openssh}/bin:${pkgs.git}/bin:${pkgs.coreutils}/bin:$PATH"

      # Prefer this user's GPG agent SSH socket if it exists
      # This ensures each user uses their own SSH keys/agent
      if [ -S "${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh" ]; then
        export SSH_AUTH_SOCK="${config.home.homeDirectory}/.gnupg/S.gpg-agent.ssh"
      fi

      REPO_PATH="${repoPath}"

      # Clone if repository doesn't exist
      if [ ! -d "$REPO_PATH/${checkDir}" ]; then
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$REPO_PATH")"
        echo "Cloning ${repo.url} (${repo.rev}) to $REPO_PATH using ${vcsName}..."
        $DRY_RUN_CMD ${cloneCmd}
      ${optionalString repo.update ''
      else
        # Update repository if update flag is set
        echo "Updating ${vcsName} repository at $REPO_PATH..."
        $DRY_RUN_CMD ${updateCmd}
      ''}
      fi
    '');

in
{
  options.home.gitClone = mkOption {
    type = types.attrsOf repoModule;
    default = {};
    description = ''
      Repositories to clone and manage using git or jj (Jujutsu).

      By default, repositories are cloned directly to the specified path.
      With `useWorktree = true`, the rev/branch name is appended to create
      a worktree-friendly structure.

      Example (default):
        home.gitClone."Coding/github.com/rytswd/emacs-config" = {
          url = "git@github.com:rytswd/emacs-config.git";
          rev = "main";
        };
      Creates: ~/Coding/github.com/rytswd/emacs-config/

      Example (worktree mode):
        home.gitClone."Coding/github.com/rytswd/emacs-config" = {
          url = "git@github.com:rytswd/emacs-config.git";
          rev = "main";
          useWorktree = true;
        };
      Creates: ~/Coding/github.com/rytswd/emacs-config/main/

      You can then add sibling worktrees:
        cd ~/Coding/github.com/rytswd/emacs-config/main
        git worktree add ../develop

      Example (using jj):
        home.gitClone."Coding/my-project" = {
          url = "git@github.com:user/project.git";
          rev = "main";
          vcs = "jj";
        };
    '';
    example = literalExpression ''
      {
        "Coding/github.com/rytswd/emacs-config" = {
          url = "git@github.com:rytswd/emacs-config.git";
          rev = "main";
          useWorktree = true;
        };
        "Coding/dotfiles" = {
          url = "https://github.com/rytswd/dotfiles.git";
          rev = "develop";
          update = true;
          vcs = "jj";
        };
      }
    '';
  };

  config = mkIf (cfg != {}) {
    home.activation = listToAttrs (
      mapAttrsToList cloneRepoScript cfg
    );
  };
}
