{ pkgs, ... }:
{
  # NOTE: Some tools such as git has dedicated modules defined to pull in.
  home.packages = [
    # NOTE: I could keep the GNU coreutils, or use uutils (rewritten in Rust)
    # version instead. When using pkgs.uutils-coreutils, I get all the uutils
    # utilities which are prefixed with "uutils-". If I want to fully replace
    # the coreutils tools, I could use pkgs.uutils-coreutils-noprefix.
    pkgs.coreutils
    pkgs.uutils-coreutils
    # pkgs.uutils-coreutils-noprefix

    pkgs.curl
    pkgs.jq
    pkgs.tree
    pkgs.watch
    pkgs.wget
  ];
}
