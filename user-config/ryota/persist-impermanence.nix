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
      # Key files I should always need
      ".cache/fontconfig"
      ".cache/nix"
      ".local/share/direnv"
      ".local/share/fonts"
      ".local/state/nix"
      # Extra application entries to be persisted, mainly for Emacs related
      # entries for outside Emacs interactions.
      ".local/share/applications"

      # Shell historise
      ".local/share/fish"
      ".local/state/zsh"

      ###----------------------------------------
      ##  Application specific
      #------------------------------------------
      # Emacs
      ".cache/mu"
      ".cache/emacs"
      ".cache/org-persist"
      ".local/share/emacs"
      ".local/state/emacs"

      # Proton
      ".cache/Proton"

      # Browsers
      ".zen"
      ".cache/vivaldi"
      ".cache/zen"

      # Steam
      ".local/share/Steam"
      ".steam"

      ###----------------------------------------
      ##  Tooling
      #------------------------------------------
      ".cache/awww"
      ".cache/starship"
      ".local/share/atuin"
      ".local/share/docker"
      ".local/share/zoxide"
      ".local/share/kubebuilder-envtest"
      ".local/share/password-store"

      ###----------------------------------------
      ##  Coding
      #------------------------------------------
      # Zig
      ".cache/zig"
      ".cache/zls"

      # Go
      ".cache/golangci-lint"
      ".cache/gopls"

      # JavaScript
      ".cache/bun"
      ".cache/pnpm"
      ".cache/mesa_shader_cache"
      ".cache/ms-playwright"
      ".cache/ms-playwright-go"
    ];
    files = [
      ".claude.json"
    ];
  };
}
