final: prev:

{
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-nu = final.lib.importJSON ./tree-sitter-grammars/nu.json;
      tree-sitter-templ = final.lib.importJSON ./tree-sitter-grammars/templ.json;
    };
  };
}
