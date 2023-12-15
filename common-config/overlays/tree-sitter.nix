final: prev:

{
  tree-sitter = prev.tree-sitter.override {
    extraGrammars = {
      tree-sitter-nu = lib.importJSON ../tree-sitter-grammars/nu.json;
    };
  };
}
