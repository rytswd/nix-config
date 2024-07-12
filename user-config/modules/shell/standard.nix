{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.standard.enable = lib.mkEnableOption "Enable standard shell tooling that should be installed in any env.";
  };

  config = lib.mkIf config.shell.standard.enable {
    home.packages = [
      pkgs.coreutils
      pkgs.curl
      pkgs.git
      pkgs.jq
      pkgs.tree
      pkgs.watch
      pkgs.wget
    ];
  };
}
