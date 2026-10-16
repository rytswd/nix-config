# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  home.persistence."/nix/persist" = {
    directories = [
      ###----------------------------------------
      ##  Common directories
      #------------------------------------------
      "Coding"
      "Documents"
      "Downloads"
      "Email"
      "Music"
      "Pictures"
      "Videos"

      ###----------------------------------------
      ##  dotfiles
      #------------------------------------------
      { directory = ".ssh"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }
      ".config" # This captures most items.

      ###========================================
      ##  XDG Cache & Data & State
      #==========================================
      # NOTE on `.cache/*`: `~/.cache` is already its own ZFS dataset
      # (`zroot/store/cache`) with `com.sun:auto-snapshot = false`. It is
      # persistent -- nothing rolls it back -- so listing a `.cache/*` path
      # here does NOT make it survive reboot; it survives either way. All an
      # entry does is relocate the blocks onto the snapshotted `persist`
      # dataset.
      #
      # So the question per path is *do I want snapshot coverage for this?*,
      # not *do I want to keep it?*. Answer yes only when the app has
      # misnamed unrecoverable state as cache. Regenerable build/HTTP caches
      # stay on the cache dataset, which is the whole point of splitting it
      # out -- see the disko comment about a corrupt cache block getting
      # pinned into snapshot history and surviving scrub + reboot.
      ".cache/nix"
      ".local/share/direnv"
      ".local/share/fonts"
      ".local/state/nix"
      # Home Manager generation gcroots -- required for standalone
      # `hm switch` state to survive across reboot / `nix-collect-garbage`;
      # harmless when only embedded HM is in use.
      ".local/state/home-manager"
      # Extra application entries to be persisted, mainly for Emacs related
      # entries for outside Emacs interactions.
      ".local/share/applications"

      # Shell historise
      ".local/share/fish"
      ".local/state/zsh"

      ###----------------------------------------
      ##  Application specific
      #------------------------------------------
      # Emacs -- `.cache/org-persist` is org state, not cache.
      ".cache/emacs"
      ".cache/org-persist"
      ".local/share/emacs"
      ".local/state/emacs"

      # Browsers -- profile only. Cookies, logins and site storage live in
      # `.zen/<profile>/storage` and `.config/vivaldi/Default`, both covered
      # here. `.cache/{zen,vivaldi}` is HTTP + V8 bytecode cache only, so it
      # is deliberately left on the cache dataset.
      ".zen"

      # Steam
      ".local/share/Steam"
      ".steam"

      ###----------------------------------------
      ##  Tooling
      #------------------------------------------
      # Noctalia v5: GUI-written settings + UI state, and installed plugins.
      # `.cache/noctalia` is misnamed -- it holds the selected wallpaper set
      # (`images/wallpapers` + `wallpapers.json`), shell layout, and paired
      # bluetooth devices. None of it regenerates.
      ".cache/noctalia"
      ".local/state/noctalia"
      ".local/share/noctalia"

      ".local/share/atuin"
      ".local/share/docker"
      ".local/share/zoxide"
      ".local/share/kubebuilder-envtest"
      ".local/share/password-store"

      # No `##  Coding` section: zig/zls, golangci-lint/gopls, bun/pnpm,
      # mesa_shader_cache and ms-playwright* were all listed here and are all
      # regenerable toolchain cache. They keep working untouched on the cache
      # dataset; persisting them only fed churn into snapshot history.
    ];
    files = [
      ".claude.json"
      ".face"
    ];
  };
}
