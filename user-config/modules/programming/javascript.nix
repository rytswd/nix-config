{ pkgs, ... }:
{
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
    pkgs.pnpm # https://pnpm.io/
    pkgs.prettier # https://prettier.io/
    pkgs.typescript # Needed for the language server

    # Language Servers
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.svelte-language-server
    pkgs.astro-language-server
  ];
}
