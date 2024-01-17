final: prev:

{
  yazi = prev.yazi.overrideAttrs (old: rec {
    version = "0.2.1-latest"; # Created for my own use case

    src = prev.fetchFromGitHub {
      owner = "sxyazi";
      repo = "yazi";
      rev = "1036685f912f162fcd5c2cd25444706217354a6a";
      sha256 = "sha256-XdN2oP5c2lK+bR3i+Hwd4oOlccMQisbzgevHsZ8YbSQ=";
    };

    # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/3
    # Ref: https://discourse.nixos.org/t/is-it-possible-to-override-cargosha256-in-buildrustpackage/4393/6
    cargoDeps = old.cargoDeps.overrideAttrs (prev.lib.const {
      name = "yazi-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-SkqcMQGNVNvQ5oMrHS4QrQiFU8PfE0woLizCgN10v+o=";
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
