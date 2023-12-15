final: prev:

{
  # Ref:
  # https://github.com/NixOS/nixpkgs/tree/master/pkgs/development/tools/parsing/tree-sitter/grammars
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-kotlin = final.lib.importJSON ./tree-sitter-grammars/kotlin.json;
      tree-sitter-nu = final.lib.importJSON ./tree-sitter-grammars/nu.json;
      tree-sitter-templ = final.lib.importJSON ./tree-sitter-grammars/templ.json;
    };
  };
}
