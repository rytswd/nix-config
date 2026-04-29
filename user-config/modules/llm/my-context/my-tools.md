---
name: my-tools
description: >-
  The user's package-manager, build-tool, editor, and local-path
  preferences on this machine. Load before suggesting `install`,
  `add`, `fetch`, build commands, or invoking an editor / formatter /
  LSP; describes which tools are allowed, which are banned, how to
  invoke one-off tools, and where repos and scratch dirs live.
---

# My Tools

## Package managers in use
- **Nixpkgs only** — system and user packages.
- System config via NixOS modules in `~/Coding/github.com/rytswd/nix-config`.
  - Do NOT update any of the configuration in my system config unless explicitly requested
- User config via home-manager (same repo, `user-config/`).
  - Do NOT update any of the configuration in my system config unless explicitly requested
- Project-scoped tools via flake devshells + direnv.

## Banned / avoid
- **Never** `nix profile install` (mutable global profile).
- **Never** distro package managers (`apt`, `dnf`, `pacman`).
- **Never** language-level globals (`npm install -g`, `pip install --user`,
  `cargo install` outside a flake), `brew`, `asdf`, `mise`.
  - `cargo install`, `go install` in some scenarios are allowed, but only if explicitly permitted
- If a tool isn't in nixpkgs / a flake input, prefer adding it as a
  flake input over reaching for a non-Nix manager.

## Preferred one-off invocation
- `nix run nixpkgs#<pkg> -- <args>` for a single command.
- `nix shell nixpkgs#<pkg> nixpkgs#<other>` for an ad-hoc shell with
  multiple tools available.
- For pinned/tested versions of project tooling, run from the flake's
  devshell (direnv handles this automatically).

## Build / test commands
- Use `nix build` and `nix flake check` when available
- Otherwise check what the project has

## Editor / LSP / formatter
- Most of the editing will be handled on Emacs
- For quick edits, nvim is used
- LSP is integrated in the editors
- Tree-sitter used for syntax handling

## Stable local paths
- Most of the coding solutions under `~/Coding/`
  - GitHub repos are under `~/Coding/github.com/`
- Scratch / experiment solutions are under `~/Coding/playground/`
