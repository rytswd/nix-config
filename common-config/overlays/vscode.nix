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
      sha256 = "190sshqpy2a0l8yj1jvhdh1jpv4cb5mbim5j8ljcy2ys1gyd278w";
    });
    version = "latest";
  });
}
