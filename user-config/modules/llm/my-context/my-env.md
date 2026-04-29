---
name: my-env
description: >-
  The user's machine and shell environment on this host: OS, distro,
  window manager, hardware notes, default shell, and how local
  secret-storage tools are reached. Load before suggesting commands
  that depend on the shell, terminal, OS, or that need to retrieve
  credentials from the user's secret store.
---

# My Environment

## Machine / OS
- NixOS laptop, Linux 6.x.
- Configuration lives in `~/Coding/github.com/rytswd/nix-config`
  (this flake). Do NOT modify it unless explicitly requested.

## Window manager / desktop
- niri (scrollable Wayland WM).

## Shell / prompt / direnv
- `direnv` is enabled across the system; project devshells autoload on
  `cd` into a directory with a `.envrc`.
- When a project has a `flake.nix` and a `.envrc`, prefer running tools
  from the devshell rather than installing them globally.

## Terminal
- Modern terminal with truecolor and Nerd Fonts; agent output should
  not avoid emoji or unicode for compatibility reasons.

