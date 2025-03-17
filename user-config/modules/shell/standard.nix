{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.standard.enable = lib.mkEnableOption "Enable standard shell tooling that should be installed in any env.";
  };

  config = lib.mkIf config.shell.standard.enable {
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
  };
}
