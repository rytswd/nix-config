# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  environment.persistence."/nix/persist" = {
    users.ryota = {
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
        ".password-store"
        ".emacs.d"
        ".ssh"
        ".gnupg"

        ###========================================
        ##  XDG Cache & Data & State
        #==========================================
        # Key files I should always need
        ".cache/fontconfig"
        ".cache/nix"
        ".local/share/direnv"
        ".local/share/fonts"

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
        ".cache/vivaldi"
        ".cache/zen"

        # Steam
        ".local/share/Steam"
        ".steam"

        ###----------------------------------------
        ##  Tooling
        #------------------------------------------
        ".cache/awww"
        ".local/share/atuin"
        ".local/share/docker"
        ".local/share/zoxide"
        ".local/share/kubebuilder-envtest"

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
        # To be updated
      ];
    };
  };
}
