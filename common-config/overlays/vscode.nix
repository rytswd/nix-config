final: prev:

let
  vscode-insider = prev.vscode.override {
    isInsiders = true;
  };
in {
  vscode-insiders = vscode-insider.overrideAttrs (old: rec {
    src = (builtins.fetchTarball {
      # NOTE: The below reference needs to be updated at the first installation,
      # but it does not seem to cause conflict or require update once it's
      # installed.
      # TODO: Check if this source mapping is actually needed. VSCode Insiders
      # get updates almost daily, and isn't something I should need to keep
      # track of the version.
      url = "https://update.code.visualstudio.com/latest/darwin-universal/insider";
      sha256 = "0z2563qn6rmsfyg273hr52zn5favqih3bpmvc3bngnm33l2y56f9";
    });
    version = "latest";
  });
}
