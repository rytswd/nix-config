{ pkgs
, lib
, config
, ...}:

# Ref: https://surrealdb.com/

{
  options = {
    service.surrealdb.enable = lib.mkEnableOption "Enable SurrealDB related tooling.";
  };

  config = lib.mkIf config.service.surrealdb.enable {
    home.packages = [
      pkgs.surrealdb
    ];
  };
}
