{ pkgs, lib, config, ... }:

let
  ryota =
    if pkgs.stdenv.isDarwin then
      {
        home = "/Users/ryota";
      }
    else
      {
        home = "/home/ryota";

        shell = pkgs.fish;

        isNormalUser = true;
        extraGroups = [
          "wheel"          # For sudo
          "input"          # For Xremap and input handling without sudo
          "uinput"         # For Xremap and input handling without sudo
          "networkmanager" # For nmcli etc.
          "docker"         # For docker
          "libvirtd"       # For VM
        ];

        # Set initial password.
        # When the `users.mutableUsers` is set, this would only apply for the new
        # user creation. User can later change the password using `passwd` command.
        initialHashedPassword = "$6$hGTdy9p9p203$8oeOAgXLzkKdo5HUkydZkEYQbWxzXgtjMsmSB76PkO6p/JWbJuJ9FhMXmhibm.XqZD58pR8hlc5EocdncS72s/"; # root
      };
in
{
  users.users.ryota = ryota;

  # When using impermanence, configure what directories get persisted.
  config = lib.mkIf config.core.boot.impermanence.enable {
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
  };
}
