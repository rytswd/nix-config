{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.javascript.enable = lib.mkEnableOption "Enable JavaScript development related tools.";
  };

  config = lib.mkIf config.programming.javascript.enable {
    home.packages = [
      pkgs.bun
      pkgs.deno
      pkgs.yarn
      pkgs.nodejs_22

      ###------------------------------
      ##   Node Packages
      #--------------------------------
      # Because of @ symbol being a part of the package name for some node
      # packages, I have to use the full path and cannot use "with pkgs;"
      # setup
      pkgs.nodePackages.pnpm        # https://pnpm.io/
      pkgs.nodePackages.prettier    # https://prettier.io/
      pkgs.nodePackages.typescript # Needed for the language server

      # Language Servers
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.svelte-language-server
      pkgs.nodePackages."@astrojs/language-server"

      # NOTE: mermaid-cli has a runtime dependency against puppeteer, which in
      # turn requires chromium binary to be made available. As I couldn't sort
      # out Chromium installation via Nix, I'm currently using Homebrew Cask
      # to install Chromium.
      # TODO: Chromium installation on NixOS needs work.
      pkgs.nodePackages.mermaid-cli # https://mermaid.js.org/ -- also known as mmdc
    ];
  };
}
