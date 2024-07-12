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
      cdt = "cd $(mktemp -d)";
      rmf = "rm -rf";

      # TODO: Add tar and tgz
      untar = "tar -xf";
      untgz = "tar -zxf";

      vi = "nvim";
    };
  };
}
