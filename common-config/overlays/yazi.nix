final: prev:

{
  yazi = prev.yazi.overrideAttrs (old: rec {
    src = prev.fetchFromGitHub {
      owner = "sxyazi";
      repo = "yazi";
      rev = "ac4afaf44eeb1b24554500b5f51037b06fb419fe";
      sha256 = "sha256-ROGd5QwY4j461rln7d5KRgHrFNtIIwar4kE/TnsYO20=";
    };

    # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
    # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/6
    cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
      name = "yazi-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-RTw9+y+pDyWEgitCaeoINO8dN5VcQoBB1LeEj4wc0Rg=";
    });

    # Needed to generate completions spec
    YAZI_GEN_COMPLETIONS = true;

    # Needed to override the installShellCompletion step
    postInstall = with prev.lib;
    let
      runtimePaths = with prev; [ file jq poppler_utils unar ffmpegthumbnailer fd ripgrep fzf zoxide ];
    in
      ''
      wrapProgram $out/bin/yazi \
        --prefix PATH : "${makeBinPath runtimePaths}"
      installShellCompletion --cmd yazi \
        --bash ./yazi-config/completions/yazi.bash \
        --fish ./yazi-config/completions/yazi.fish \
        --zsh  ./yazi-config/completions/_yazi
      '';
  });
}
