# Home Manager profile for headless servers I own end-to-end (e.g.
# ryota-aws-ec2-devbox).
#
# Same lean SSH-only subset as `coder.nix`, with two deliberate differences:
#   - `vcs` bundle IS imported: on my own boxes nothing else manages git/jj
#     config, so home-manager should (on Coder workspaces it must not).
#   - Identity is fixed to `ryota`: the account is created by the host's
#     NixOS config, not by whoever happens to run the switch.
#
# Used both integrated (home-manager.users.ryota in the host's default.nix)
# and standalone (`home-manager switch --flake .#ryota@<host>`) — same file,
# so day-to-day dotfile tweaks don't need sudo, while a fresh
# nixos-anywhere install still produces a fully-configured box in one shot.
{
  self,
  ...
}:
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
    # zsh/bash/fish/nushell, starship, atuin, direnv, tmux, yazi, etc.
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
    ##  VCS — git + jj config owned by home-manager here
    #------------------------------------------
    "${self}/user-config/modules/vcs"

    ###----------------------------------------
    ##  Repo cloning
    #------------------------------------------
    "${self}/user-config/ryota/home-git-clone.nix"

    ###----------------------------------------
    ##  Secret handling (no-op without a key)
    #------------------------------------------
    # Imported so `sops.*` / `local.secrets.enable` options exist; disabled
    # below until the box gets a decryption key.
    "${self}/user-config/modules/security/sops-nix.nix"
    "${self}/user-config/modules/security/sops.nix"
  ];

  # No sops key provisioned on servers (yet) — secret-defining modules fall
  # back to their non-secret config.
  local.secrets.enable = false;

  home = {
    username = "ryota";
    homeDirectory = "/home/ryota";
    stateVersion = "25.11";
  };
}
