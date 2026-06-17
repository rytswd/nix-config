# Home Manager profile for Coder workspaces.
#
# A lean, SSH-only, headless subset of the full Ryota HM profile. Compared
# to `nixos.nix` / `macos.nix` this drops everything desktop / windowing /
# media / GUI-terminal / GUI-editor related, plus all secret handling that
# needs a key the workspace doesn't have.
#
# Key differences from the desktop profiles, and why:
#   - No `terminal` bundle (ghostty / alacritty are GUI terminal emulators,
#     pointless over SSH). tmux still comes in via the `shell` bundle.
#   - Editors: terminal neovim + helix only. No vscode / zed (GUI) and no
#     emacs (heavy build, opt-in if needed).
#   - git / jj: only the binaries are provided. Their config is managed
#     separately in this env (outside home-manager), so the shared
#     `vcs/git` + `vcs/jj` modules -- which write opinionated config, wire
#     up signing, and pull in the YubiKey module -- are NOT imported.
#   - `local.secrets.enable = false`: no sops decryption key here, so
#     secret-defining modules use their non-secret fallbacks instead of
#     failing at activation.
#
# Activated via standalone HM:
#   - `nix run github:rytswd/nix-config` (the bootstrap app), or
#   - `nix run .#hm -- switch`, or
#   - `home-manager switch --flake .#coder`.
#
# Username / home directory are read from $USER / $HOME at activation
# (via `--impure`), so this profile works for whichever user runs it;
# the `ryota` literal below is only the pure-eval fallback for
# `nix flake check`.
#
# ---------------------------------------------------------------------------
# Pluggable local ("private") overlay
# ---------------------------------------------------------------------------
# This profile is fully public and org-agnostic. Anything environment-specific
# (e.g. work/in-house logic) is layered on as a *local dependency*, never
# referenced from this repo, via two independent seams:
#
#   1. Nix layer -- `localProfile` below. Drop a Home Manager module at
#      `~/.config/home-manager/local.nix` (or point $NIX_CONFIG_LOCAL_PROFILE
#      at one) and it is merged into this profile. Absent -> no-op. Because it
#      is a plain local path (not a flake input), it needs no SSH and pulls no
#      sops-nix / secret machinery.
#
#   2. Shell layer -- `~/.config/zsh/local.zsh`, sourced last by the generated
#      zshrc (see user-config/modules/shell/zsh.nix). This restores the
#      in-house shell chain (aliases, commands, PATH, e.g. dotfiles `base.sh`).
{
  config,
  pkgs,
  lib,
  inputs,
  self,
  ...
}:
let
  # Optional local overlay module. Read from the environment rather than
  # `config.*` because `imports` must not depend on `config` (that recurses).
  # `--impure` (passed by the bootstrap app) is required to see real values;
  # under pure eval -- e.g. `nix flake check` -- getEnv returns "", so the
  # candidate is empty and nothing is layered, keeping `ryota@coder` evaluable.
  localProfile =
    let
      override = builtins.getEnv "NIX_CONFIG_LOCAL_PROFILE";
      home = builtins.getEnv "HOME";
      default = if home != "" then "${home}/.config/home-manager/local.nix" else "";
      candidate = if override != "" then override else default;
    in
    lib.optional (candidate != "" && builtins.pathExists candidate) candidate;
in
{
  imports = [
    ###----------------------------------------
    ##  Library helpers
    #------------------------------------------
    "${self}/user-config/modules/lib/paths.nix"

    ###----------------------------------------
    ##  Home Manager itself
    #------------------------------------------
    "${self}/user-config/modules/home-manager"

    ###----------------------------------------
    ##  Shell + multiplexer
    #------------------------------------------
    # Brings in zsh/bash/fish/nushell, starship, atuin (local-only here),
    # direnv, tmux, yazi, etc.
    "${self}/user-config/modules/shell"

    ###----------------------------------------
    ##  Editors (terminal only)
    #------------------------------------------
    "${self}/user-config/modules/editor/neovim"
    "${self}/user-config/modules/editor/helix.nix"

    ###----------------------------------------
    ##  Dev tooling
    #------------------------------------------
    "${self}/user-config/modules/programming"
    "${self}/user-config/modules/kubernetes"
    "${self}/user-config/modules/llm"
    "${self}/user-config/modules/product/cloud"
    "${self}/user-config/modules/product/vcs"

    ###----------------------------------------
    ##  Repo cloning
    #------------------------------------------
    # Shared with the desktop profiles -- the path prefix is derived from
    # `local.ghRoot` so the same list lands under `~/src/github.com/...`
    # here. SSH auth comes from the workspace's own ssh-agent, which
    # `home-git-clone` discovers if SSH_AUTH_SOCK isn't inherited.
    "${self}/user-config/ryota/home-git-clone.nix"

    ###----------------------------------------
    ##  Secret handling (no-op without a key)
    #------------------------------------------
    # sops-nix is still imported so the `sops.*` options exist (modules
    # reference them even when gated off) and `local.secrets.enable` is in
    # scope. With secrets disabled below, no secrets are defined, so
    # activation is a no-op. `sops.nix` just puts the `sops` CLI on PATH.
    "${self}/user-config/modules/security/sops-nix.nix"
    "${self}/user-config/modules/security/sops.nix"

    ###----------------------------------------
    ##  Intentionally excluded on coder workspaces
    #------------------------------------------
    # terminal/ (GUI emulators), editor/{vscode,zed,emacs}, security/{gpg,
    # pass,age,pam-u2f}, the whole vcs/ bundle (git + jj config managed
    # separately here), and all desktop / windowing / media / sync
    # concerns. Re-add per-workspace by direct import if needed.
    #
    # Also excluded: swapdir is now in the shared shell bundle.
  ]
  # Pluggable local overlay -- empty unless a local module is present. See the
  # header note. Kept last so it can override anything above.
  ++ localProfile;

  ###----------------------------------------
  ##  Secret handling
  #------------------------------------------
  # SSH-only workspace with no decryption key -- secret-defining modules
  # fall back to non-secret config (see user-config/modules/lib/secrets.nix).
  local.secrets.enable = false;

  ###----------------------------------------
  ##  Identity -- follow whoever runs the switch
  #------------------------------------------
  # The workspace user is out of our control (Coder images may run as
  # `coder`, `root`, a service account, ...), and home-manager asserts that
  # `home.username` matches $USER at activation. So read the real user/home
  # from the environment instead of hardcoding a name.
  #
  # `builtins.getEnv` only sees real values under `--impure` (the bootstrap
  # app passes it). Under pure eval -- e.g. `nix flake check` -- getEnv
  # returns "", so we fall back to `ryota` / `/home/<user>` to keep the
  # `ryota@coder` output evaluable.
  #
  # mkDefault so a specific workspace can still override if needed.
  home.username = lib.mkDefault (
    let u = builtins.getEnv "USER"; in if u != "" then u else "ryota"
  );
  home.homeDirectory = lib.mkDefault (
    let h = builtins.getEnv "HOME"; in
    if h != "" then h else "/home/${config.home.username}"
  );

  ###----------------------------------------
  ##  Source checkout location
  #------------------------------------------
  # Coder wipes $HOME on workspace restart, but the `$HOME/src` volume is
  # persistent (the env signals this with CODER_WORKSPACE_USE_ROOT_SRC_DIRECTORY
  # and keeps its own checkouts there). So `codeRoot` moves to `$HOME/src`;
  # `ghRoot` then derives `$HOME/src/github.com`, and my checkouts -- including
  # this repo -- live under `$HOME/src/github.com/<owner>/<repo>`, NOT under
  # `$HOME/Coding`. This feeds `local.repoPath` (mkOutOfStoreSymlink targets)
  # and the local-skill paths in llm/skills.nix. See lib/paths.nix.
  #
  # NB: cloning the repo to this path is the workspace's responsibility (HM
  # only references it); keep it at `${config.local.repoPath}`.
  local.codeRoot = lib.mkDefault "${config.home.homeDirectory}/src";

  # Kubernetes contributor repos are personal-only; skip on work machines.
  local.clone.kubernetes = false;

  # Prompt identity: the stock p10k.zsh carries `host_label` / `user_label`
  # / `auth_status` segments that read generic P10K_* env vars (blank when
  # unset). Map the workspace's own values onto them in the untracked
  # `~/.config/zsh/local.zsh`, e.g.:
  #
  #   export P10K_HOST_LABEL="$SOME_WORKSPACE_NAME"
  #   export P10K_USER_LABEL="$SOME_OWNER_VAR"
  #   _p10k_auth_status() { needs_reauth && P10K_AUTH_STATUS="re-auth" || P10K_AUTH_STATUS=; }
  #   precmd_functions+=(_p10k_auth_status)
  #
  # so no environment-specific names appear in this repo.

  ###----------------------------------------
  ##  User-level nix.conf
  #------------------------------------------
  # The workspace's system `/etc/nix/nix.conf` only enables `nix-command` +
  # `fetch-tree`, not `flakes` / `pipe-operators`. The bootstrap app papers
  # over that by exporting NIX_CONFIG, but day-to-day `nix run .#hm` does
  # not. Write a user-level `~/.config/nix/nix.conf` so the features stick
  # after the first switch and the env-var prefix is only needed once.
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "pipe-operators"
  ];

  ###----------------------------------------
  ##  Keep the workspace's seeded nix profile intact
  #------------------------------------------
  # The workspace image ships `~/.local/state/nix/profiles/profile` as a
  # direct symlink to a raw `dev-env` store path (no manifest.nix /
  # manifest.json). Standalone HM's default `installPackages` step runs
  # `nix-env -i <home-manager-path>` against that same default profile;
  # with no manifest to merge into, nix-env builds a fresh user-environment
  # containing ONLY home-manager-path -- silently dropping every seeded
  # tool (git, aws, kubectl, ...) and requiring a `nix profile rollback`
  # to recover.
  #
  # Override that step to install into a dedicated side-profile instead,
  # and point `~/.nix-profile` at it. The seeded default profile is never
  # touched, and HM packages still appear on PATH via `~/.nix-profile/bin`
  # (which is what `home.profileDirectory` resolves to here).
  home.activation.installPackages =
    let
      sideProfile = "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager-packages";
    in
    lib.mkForce (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$(dirname "${sideProfile}")"
        run nix-env --profile "${sideProfile}" --set ${config.home.path}
        run ln -sfn "${sideProfile}" "$HOME/.nix-profile"
      ''
    );

  # The workspace's nix profile hook only adds the XDG-style
  # `~/.local/state/nix/profile/bin` to PATH, not `~/.nix-profile/bin`, so
  # the side profile created above would be invisible. Add it explicitly --
  # this lands in `hm-session-vars.sh`, which `.zshenv` sources for every
  # shell.
  home.sessionPath = [ "$HOME/.nix-profile/bin" ];

  ###----------------------------------------
  ##  Persist volatile state across restarts
  #------------------------------------------
  # $HOME is on an ephemeral overlay; `/root/home` is a persistent volume
  # (the env itself symlinks ~/.claude, ~/.netrc, ... into it). Mirror that
  # convention for runtime state that is neither workspace- nor HM-managed,
  # so shell history etc. survive a workspace recycle: real data under the
  # persistent volume, a symlink at the $HOME location.
  #
  # NOT persisted here: ~/.config/gh (gh's token is keyring-backed, not in
  # the config dir, so the workspace owns that), and anything the env or HM
  # already manages.
  home.activation.coder-persist = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    persist_root="/root/home/hm-persist"

    # _persist <path-relative-to-$HOME> <file|dir>
    _persist() {
      rel="$1"; kind="$2"
      link="$HOME/$rel"; target="$persist_root/$rel"
      mkdir -p "$(dirname "$target")" "$(dirname "$link")"
      # Seed the persistent copy from any pre-existing real (non-symlink)
      # data, then drop the original so the symlink can take its place.
      if [ -e "$link" ] && [ ! -L "$link" ]; then
        [ -e "$target" ] || cp -a "$link" "$target"
        rm -rf "$link"
      fi
      # Make sure the target exists so the symlink never dangles.
      if [ ! -e "$target" ]; then
        if [ "$kind" = dir ]; then mkdir -p "$target"; else : > "$target"; fi
      fi
      [ -L "$link" ] || ln -sfn "$target" "$link"
    }

    if [ -d /root/home ]; then
      _persist ".local/share/atuin"    dir   # shell history database
      _persist ".local/state/zsh"      dir   # zsh_history lives here
      _persist ".config/zsh/local.zsh" file  # private shell hook (sources base.sh)
    fi
  '';

  # Cross-cycle stability: bump only when consciously migrating.
  home.stateVersion = "25.11";
}
