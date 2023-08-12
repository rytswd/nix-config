{ pkgs, ... }:

{
  enable = true;
  shellAliases =
    (import ./aliases-ls.nix { withExa = true; }) //
    {
      # Any aliases specific for bash can be defined here.

      # Temporary alias for setting up Homebrew PATH for the current session.
      brewsup = "export PATH=\"/opt/homebrew/bin:/opt/homebrew/sbin:${PATH+:$PATH}\"";
    };
}
