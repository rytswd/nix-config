final: prev:

{
  # Ref:
  # https://github.com/NixOS/nixpkgs/tree/master/pkgs/development/tools/parsing/tree-sitter/grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-astro = final.lib.importJSON ./tree-sitter-grammars/astro.json;
      tree-sitter-kotlin = final.lib.importJSON ./tree-sitter-grammars/kotlin.json;
      tree-sitter-nu = final.lib.importJSON ./tree-sitter-grammars/nu.json;
      tree-sitter-templ = final.lib.importJSON ./tree-sitter-grammars/templ.json;
      # tree-sitter-sql = final.lib.importJSON ./tree-sitter-grammars/sql.json;
      tree-sitter-roc = final.lib.importJSON ./tree-sitter-grammars/roc.json;
      tree-sitter-hcl = final.lib.importJSON ./tree-sitter-grammars/hcl.json;
    };
  };
}
