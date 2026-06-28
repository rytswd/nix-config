# Public no-op stand-in for the `nix-config-private` flake input.
#
# WHY THIS EXISTS
#   `nix-config-private` is a `git+ssh` input, which makes private-repo SSH
#   access an *eval-time* hard dependency for every full profile. A brand-new
#   machine (no SSH key yet) cannot evaluate or dry-build anything until that
#   credential exists. This stub provides the way around the wall without
#   tearing it down: substitute it for the real input and any host evaluates
#   in a clearly-degraded mode. See air/v0.1/private-input-stub.org.
#
# USAGE (degraded eval/build, no credential needed)
#   From a checkout:
#       nixos-rebuild build --flake .#<host> \
#           --override-input nix-config-private path:./stubs/nix-config-private
#   Without any clone (GitHub tarball API, no SSH -- same trick as the
#   `treesitter-grammars` input):
#       --override-input nix-config-private \
#           'github:rytswd/nix-config?dir=stubs/nix-config-private'
#   Upgrade to a full build by installing a credential (see
#   docs/runbooks/credential-bootstrap.org) and rebuilding WITHOUT the
#   override; nothing else changes.
#
# THE CONTRACT
#   This file is the single public record of the private flake's interface:
#   every attribute the public repo consumes from `inputs.nix-config-private`
#   must exist here as a no-op (or minimal-safe) module. UPDATE RULE: when the
#   private flake grows an attribute that this repo starts referencing, the
#   stub grows the matching no-op in the same change -- never later. Drift is
#   caught mechanically by `checks.<system>.private-stub-interface` (see
#   checks.nix); run it with the stub override since evaluating any check
#   forces the private input otherwise:
#       nix build .#checks.x86_64-linux.private-stub-interface \
#           --override-input nix-config-private path:./stubs/nix-config-private
#
#   Interface shape only lives here -- attribute names and the minimum safe
#   values to keep public modules evaluating. No real secrets, identities, or
#   organisation-specific data, ever.
{
  description = "Public no-op stub for the nix-config-private flake input";

  # The parent flake declares `follows` for exactly these three inputs on
  # `nix-config-private`; an override target that doesn't declare them makes
  # every `follows` dangle (warnings at best). Declared but intentionally
  # unused -- the stub's outputs must not depend on anything fetchable.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    { self, ... }:
    let
      # One warning per consumed module, so a degraded eval *says* it is
      # degraded instead of silently producing a system with missing pieces.
      # Both NixOS and Home Manager aggregate `warnings` and print them at
      # build/activation time.
      stubWarning = attr: missing: {
        warnings = [
          "nix-config-private STUB: `${attr}` is a no-op (degraded build) -- ${missing}. Install a credential and rebuild without the stub override for the full configuration."
        ];
      };
    in
    {
      ###----------------------------------------
      ##  NixOS modules
      #------------------------------------------
      # Real module: attaches `hashedPassword` (and related identity data) to
      # the users declared publicly in user-config/*/create.nix. Under the
      # stub, users are still created but keep whatever fallback the public
      # config defines -- on hosts where create.nix sets no password, that
      # means NO usable login for the affected account. Check the host's
      # create.nix before shipping a degraded system anywhere that matters.
      nixosModules.users = { ... }: stubWarning "nixosModules.users" "no hashedPassword / identity data is attached to users";

      ###----------------------------------------
      ##  Home Manager modules
      #------------------------------------------
      homeManagerModules = {
        # Real module: points `sops.age.keyFile` at the host's age key and
        # defines the actual secrets. The `sops.*` options themselves come
        # from the public security bundle (user-config/modules/security/
        # sops-nix.nix), so the stub only needs values that keep eval alive:
        # public modules (e.g. user-config/modules/vcs/git/yubikey.nix)
        # declare secrets whose `sopsFile` lives inside this flake via
        # `toString inputs.nix-config-private`, so the *file path* is part of
        # the consumed interface too -- hence keys/ssh/yubikey-stub.yaml next
        # to this file (see its header for why it exists despite eval not
        # strictly requiring it). Decryption is impossible by construction
        # here; a degraded activation skips real secret material.
        sops-nix = { ... }: stubWarning "homeManagerModules.sops-nix" "no age key and no real secrets are configured";

        # Real module: account definitions under `accounts.email.accounts.*`.
        # The public communication bundle already guards on "at least one
        # account exists" (user-config/modules/communication/email.nix), so
        # an empty stub cleanly disables notmuch and friends.
        email = { ... }: stubWarning "homeManagerModules.email" "no email accounts are defined";

        # Real module: private git identity/config (email, work remotes).
        # Public git config (user-config/modules/vcs/git) stands alone, so
        # empty is safe -- commits made on a degraded machine just lack the
        # private identity bits.
        git = { ... }: stubWarning "homeManagerModules.git" "private git identity/config is absent";
      };
    };
}
