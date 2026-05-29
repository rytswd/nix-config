{ pkgs, ... }:
{
  home.packages = [
    pkgs.pandoc

    # Using Go implementation instead, which does not rely on using GitHub
    # API, and which means there is no need of token setup.
    pkgs.go-grip

    # https://mermaid.js.org/ — also known as `mmdc`. Renders Mermaid
    # diagrams (typically embedded in fenced ```mermaid blocks in Markdown)
    # into PNG/SVG/PDF as part of doc-conversion workflows alongside pandoc.
    #
    # NOTE: mermaid-cli has a runtime dependency on puppeteer, which in
    # turn needs a Chromium binary on PATH. Chromium installation via Nix
    # is unresolved here — on macOS the current workaround is to install
    # Chromium via Homebrew Cask. TODO: revisit on NixOS.
    pkgs.mermaid-cli

    # pkgs.python314.pkgs.grip # https://github.com/joeyespo/grip
    # pkgs.python-grip # Overlay in place for the above to get the latest master.
  ];
}
