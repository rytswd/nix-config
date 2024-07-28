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
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
      pkgs.tree
      pkgs.watch
      pkgs.wget
    ];
  };
}
