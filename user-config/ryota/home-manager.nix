{ config, pkgs, username, ... }:

# let
#   # emacs-overlay = import (fetchTarball {
#   #     url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
#   #     sha256 = "1jppksrfvbk5ypiqdz4cddxdl8z6zyzdb2srq8fcffr327ld5jj2";
#   #   });
#   # nixpkgs-with-emacs = import (builtins.fetchTarball {
#   #   url = "https://github.com/NixOS/nixpkgs/archive/5f98e7c92b1a7030324c85c40fa0b46e0ba4cb23.tar.gz";
#   #   sha256 = "sha256:1i2f7hfw5xp3hhkaaq8z6z9bhdx5yf2j65pmg4f1wxv4d0dswfpi";
#   # }) {};
#   # emacs-29-macport = nixpkgs-with-emacs.emacs.override {
#   #   withNativeCompilation = true;
#   #   withSQLite3 = true;
#   #   withTreeSitter = true;
#   #   withWebP = true;
#   # };

#   # NOTE: This macport installation fails with clang-wrapper / compiler-rt dependencies.
#   # my-emacs = pkgs.emacs29-macport.override {
#   my-emacs = pkgs.emacs29.override {
#     withNativeCompilation = true;
#     withSQLite3 = true;
#     withTreeSitter = true;
#     withWebP = true;
#   };
#   my-emacs-with-packages = (pkgs.emacsPackagesFor my-emacs).emacsWithPackages (epkgs: with epkgs; [
#     vterm
#     multi-vterm
#     jinx    # https://github.com/minad/jinx
#   ]);
# in
{
  home = {
    # NOTE: This state version failed to build once -- it seems OK now.
    stateVersion = "23.05";
    # stateVersion = "22.11";

    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages =
      import(../../common-config/home-manager/packages.nix) { inherit pkgs; }
      ++ pkgs.lib.attrValues {
        inherit (pkgs)
          # + Additional Utilities
          du-dust   # https://github.com/bootandy/dust
          bandwhich # https://github.com/imsnif/bandwhich
          mkcert    # https://github.com/FiloSottile/mkcert
          bottom    # https://github.com/ClementTsang/bottom
          htop      # https://github.com/htop-dev/htop
          pass      # https://www.passwordstore.org/
          git-lfs   # https://github.com/git-lfs/git-lfs
          zellij    # https://github.com/zellij-org/zellij
          tree-sitter # https://github.com/tree-sitter/tree-sitter

          # + More Utilities
          # These can be somewhat env specific.
          # authy
          keybase

          # + Kubernetes
          docker
          kubectl
          kind
          krew
          k9s
          kube3d
          kubectx
          pinniped

          # + Coding
          deno
          go    # Needed because Vim plugin govim requires this.
          gopls

          yarn
          pandoc      # Markdown support
          shellcheck  # I want this for any code base
          clang-tools

          # + Editors
          # emacs         # This is defined below in the program section.
          vscode
          vscode-insiders # Added from the overlay setup

          # + Other UI Tools
          discord
          slack
          zoom-us
          # rectangle # https://rectangleapp.com/ # No longer using this as I'm now using Raycast.

          # + Services
          awscli

          # + Other Tools
          # surrealdb # TODO: This is failing to build now.
        ;
      }
      # Python setup
      ++ (with pkgs; [
        python311
        poetry
        python311.pkgs.pip
      ])
      # Node.js related setup
      ++ (with pkgs.nodePackages; [
        pnpm
        prettier
      ])
      # Dictionaries
      ++ [
        # pkgs.enchant  # https://github.com/AbiWord/enchant
        (pkgs.aspellWithDicts (dicts: with dicts; [
          en
          en-computers
          en-science
        ]))
        (pkgs.hunspellWithDicts (with pkgs.hunspellDicts; [
          en_GB-large
          en_US
        ]))
        # Other packages
        # pkgs.nuspell   # https://github.com/nuspell/nuspell
      ]
      # JetBrains setup
      ++ [
        # pkgs.jetbrains.idea-ultimate
        # pkgs.jetbrains.idea-community
      ]
      # + GCP specific setup
      # Ref: https://github.com/NixOS/nixpkgs/issues/99280
      # TODO: Consider removing this from Home Manager, it is quite annoying
      # how slow it is to fetch the source.
      ++ [
        (with pkgs.google-cloud-sdk;
          withExtraComponents ([ components.gke-gcloud-auth-plugin ])
        )
      ]
      # + Other
      ++ [
        (import ../../common-config/overlays/erdtree.nix { inherit (pkgs) lib rustPlatform fetchFromGitHub; }) # Install erdtree directly
        # (import ../../common-config/overlays/mirrord.nix { inherit pkgs; }) # mirrord isn't available in nixpkgs
      ]
    ;

    # Any aliases defined here will be concatanated with the aliases defined in
    # shell specific setup. If there is a conflict, it would result in an error.
    shellAliases =
      (import ../../common-config/home-manager/aliases-basic.nix) //
      {
        # Any aliases defined here will override the ones defined prior to this.
        k = "kubectl";
        gccact = "gcloud config configurations activate";
        gccls = "gcloud config configurations list";
      };

    # Environment variables
    sessionVariables = {
      EDITOR = "vim";
      LESS = "-iMNR";
      # TODO: Add DIRENV_LOG_FORMAT to be an empty string to suppress the output
    };
  };

  programs = {
    home-manager.enable = true;

    emacs = import ../../common-config/home-manager/emacs.nix { inherit pkgs; };

    # + Terminals
    alacritty = {
      enable = true;
    };
    kitty = {
      enable = true;
    };

    # + Shells
    # Because there are some nuances based on shell, and thus the actual
    # configurations are managed in separate files.
    bash = import ../../common-config/home-manager/bash.nix { inherit pkgs; };
    fish = import ../../common-config/home-manager/fish.nix { inherit pkgs; };
    zsh  = import ../../common-config/home-manager/zsh.nix  { inherit pkgs; };

    tmux = import ../../common-config/home-manager/tmux.nix { inherit pkgs; };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      # Starship configuration can be defined with the `settings` attribute, but
      # as it is not as intuitive as TOML format, I'm rather simply copying the
      # TOML file over using `xdg.configFile`.
      # settings = { SOME NIX LANG BASED SETTING };

      # Specifically turning off ZSH integration, as Powerlevel10k provides
      # better feedback.
      enableZshIntegration = false;
    };

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      # enableNushellIntegration = true; # Commenting out as I'm not using Nushell at the moment
    };

    # + Editors
    vscode = {
      enable = true;
      # I'm not managing extensions via home-manager.
      # extensions = with pkgs.vscode-extensions; [
      # dracula-theme.theme-dracula
      # vscodevim.vim
      # yzhang.markdown-all-in-one
      # ];
    };

    # + Coding
    go = {
      enable = true;
      goPath = "Coding/go";
      goBin = "Coding/go/bin";
      goPrivate = [ "github.com/rytswd" "github.com/upsidr" ];
    };

    # + Utilities
    gpg = {
      enable = true;
    };
  };

  xdg = {
    enable = true;
    configFile = {
      # Instead of using programs.starship.settings, copy the TOML file over.
      "starship.toml".source = ../../common-config/starship.toml;

      "alacritty/alacritty.yml".source = ./alacritty.yaml;

      "bat/config".source = ./bat-config.sh;

      "git".source = ../../common-config/git;
      "git".recursive = true;

      # Providing the below config via programs.tmux instead.
      # "tmux/tmux.conf".source        = ../../common-config/tmux/tmux.conf;
      "tmux/keybindings.conf".source = ../../common-config/tmux/keybindings.conf;
      "tmux/options.conf".source     = ../../common-config/tmux/options.conf;
      # "tmux/tpm.conf".source         = ../../common-config/tmux/tpm.conf;

      # ZSH abbreviation with https://github.com/olets/zsh-abbr needs a
      # dedicated configuration file.
      "zsh-abbr/user-abbreviations".source = ../../common-config/zsh/zsh-abbr.txt;
    };
  };
}
