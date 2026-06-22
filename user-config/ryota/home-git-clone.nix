{
  config,
  lib,
  inputs,
  ...
}:
let
  # Keys are paths relative to $HOME. Derive the prefix from `local.ghRoot`
  # (see lib/paths.nix) so the same definition lands under
  # `~/Coding/github.com/...` on a desktop and `~/src/github.com/...` on a
  # workspace without per-host edits.
  ghRel = lib.removePrefix "${config.home.homeDirectory}/" config.local.ghRoot;
  at = owner: repo: "${ghRel}/${owner}/${repo}";
  ssh = owner: repo: "git@github.com:${owner}/${repo}.git";
in
{
  imports = [ inputs.home-git-clone.homeManagerModules.default ];

  ###----------------------------------------
  ##   Per-host clone toggles
  #------------------------------------------
  # Sections below that are not wanted on every host (e.g. a work
  # workspace) are gated on these. Defaults match the desktop profiles;
  # other profiles flip individual flags off.
  options.local.clone = {
    kubernetes = lib.mkEnableOption "Kubernetes contributor repo checkouts" // {
      default = true;
    };
  };

  config = lib.mkMerge [
    ###----------------------------------------
    ##   Key Repositories
    #------------------------------------------
    {
      home.gitClone = {
        ${at "rytswd" "nix-config"}.url = ssh "rytswd" "nix-config";
        ${at "rytswd" "emacs-config"}.url = ssh "rytswd" "emacs-config";
        ${at "rytswd" "nix-config-private"}.url = ssh "rytswd" "nix-config-private";
      };
    }

    ###----------------------------------------
    ##   Active Projects
    #------------------------------------------
    {
      home.jjClone = {
        ${at "withre" "zig-cli-kit"}.url = ssh "withre" "zig-cli-kit";
        ${at "withre" "zignix"}.url = ssh "withre" "zignix";
        ${at "withre" "air"}.url = ssh "withre" "air";
        ${at "withre" "chronoa"}.url = ssh "withre" "chronoa";
        ${at "withre" "ever"}.url = ssh "withre" "ever";
        ${at "withre" "ace-stack"}.url = ssh "withre" "ace-stack";
      };
    }

    ###----------------------------------------
    ##   Active Personal Projects
    #------------------------------------------
    {
      home.jjClone = {
        ${at "rytswd" "skills.nix"}.url = ssh "rytswd" "skills.nix";
        ${at "rytswd" "home-git-clone"}.url = ssh "rytswd" "home-git-clone";
        ${at "rytswd" "pi-agent-extensions"}.url = ssh "rytswd" "pi-agent-extensions";
        ${at "rytswd" "pi-agent-extensions-extra"}.url = ssh "rytswd" "pi-agent-extensions-extra";
        ${at "rytswd" "ren"}.url = ssh "rytswd" "ren";
        ${at "rytswd" "swapdir"}.url = ssh "rytswd" "swapdir";
      };
    }

    ###----------------------------------------
    ##   Kubernetes
    #------------------------------------------
    (lib.mkIf config.local.clone.kubernetes {
      home.gitClone = {
        ${at "rytswd" "sig-release"}.url = ssh "rytswd" "sig-release";
        ${at "rytswd" "k8s.io"}.url = ssh "rytswd" "k8s.io";
        ${at "rytswd" "k8s-enhancements"}.url = ssh "rytswd" "k8s-enhancements";
        ${at "rytswd" "k8s-org"}.url = ssh "rytswd" "k8s-org";
        ${at "rytswd" "k8s-website"}.url = ssh "rytswd" "k8s-website";
      };
    })
  ];
}
