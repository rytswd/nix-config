# Home Manager profile for headless servers I own end-to-end (e.g.
# ryota-aws-ec2-devbox).
#
# Same lean SSH-only subset as `coder.nix`, with three deliberate differences:
#   - `vcs` bundle IS imported: on my own boxes nothing else manages git/jj
#     config, so home-manager should (on Coder workspaces it must not).
#   - Identity is fixed to `ryota`: the account is created by the host's
#     NixOS config, not by whoever happens to run the switch.
#   - Secrets at the ephemeral tier: these boxes are mine end-to-end, so
#     they get enrolled per-instance keys (coder workspaces stay keyless).
#
# Used both integrated (home-manager.users.ryota in the host's default.nix)
# and standalone (`home-manager switch --flake .#ryota@<host>`) — same file,
# so day-to-day dotfile tweaks don't need sudo, while a fresh
# nixos-anywhere install still produces a fully-configured box in one shot.
{
  self,
  inputs,
  lib,
  config,
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
    ##  Secret handling (ephemeral tier)
    #------------------------------------------
    # Public side: `sops.*` / `local.secrets.*` options + the sops CLI.
    "${self}/user-config/modules/security/sops-nix.nix"
    "${self}/user-config/modules/security/sops.nix"
    # Private side: the actual secret definitions (same module nixos.nix
    # imports). This deliberately reverses the "server profile evaluates
    # without the private input" property that the keyless era of this file
    # had: these boxes are provisioned from a machine that already holds
    # private-repo access (docs/runbooks/remote-provision.org), so forcing
    # the input here costs nothing in practice — and keyless machines still
    # have the stub override (stubs/nix-config-private) for degraded evals.
    inputs.nix-config-private.homeManagerModules.sops-nix
  ];

  # Enrolled instance: a per-instance age key gives this box the ephemeral
  # class only — core-class modules keep falling back as if secrets were
  # disabled. Lifecycle (and the revoke-on-teardown obligation) in
  # docs/runbooks/secrets-enrolment.org.
  local.secrets = {
    enable = true;
    tier = "ephemeral";
  };

  # The private module points `sops.age.keyFile` at the YubiKey-machine
  # layout (a sops-nix specific path populated from host keys decrypted by
  # a YubiKey) — nothing ever creates that file here. This box's identity
  # is the user-level key generated at enrolment time, living at the HM
  # sops-nix default path; mkForce because the private module's definition
  # is a plain (same-priority) assignment.
  sops.age.keyFile = lib.mkForce "${config.xdg.configHome}/sops/age/keys.txt";

  home = {
    username = "ryota";
    homeDirectory = "/home/ryota";
    stateVersion = "25.11";
  };
}
