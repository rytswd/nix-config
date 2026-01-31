{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.aliases.enable = lib.mkEnableOption "Enable Markdown related tools.";
  };

  config = lib.mkIf config.shell.aliases.enable {
    # NOTE: `ls` related aliases are defined separately, as I do want to use eza
    # in bash and fish, but would like to keep using the builtin `ls` on zsh.
    home.shellAliases = {
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      c = "clear";
      # NOTE: This breaks Nushell, and thus taking it out. Other shell can
      # have a dedicated definition for this support.
      # cdt = "cd $(mktemp -d)";
      rmf = "rm -rf";

      # Compression / Decompression
      tar = "tar -cf";
      untar = "tar -xf";
      tgz = "tar -zcf";
      untgz = "tar -zxf";
      lstar = "tar -tf";
      lstgz = "tar -ztf";

      vi = "nvim";
    };
  };
}
