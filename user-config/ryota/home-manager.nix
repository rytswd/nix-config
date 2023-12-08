{ config, pkgs, username, ... }:

{
  # TODO: Work around for build error relating to 'mistune.renderers' has no attribute 'BaseRenderer'.
  manual.manpages.enable = false;

  home = {
    stateVersion = "23.05";

    username = "${username}";
    homeDirectory = "/Users/${username}";

    packages =
      # Some common packages I use for any envs are bundled in a separate file.
      import(../../common-config/home-manager/packages.nix) { inherit pkgs; }
      ++ pkgs.lib.attrValues {
        inherit (pkgs)
          ###------------------------------
          ##   Additional Utilities
          #--------------------------------
          du-dust   # https://github.com/bootandy/dust
          bandwhich # https://github.com/imsnif/bandwhich
          mkcert    # https://github.com/FiloSottile/mkcert
          bottom    # https://github.com/ClementTsang/bottom
          htop      # https://github.com/htop-dev/htop
          pass      # https://www.passwordstore.org/
          git-lfs   # https://github.com/git-lfs/git-lfs
          zellij    # https://github.com/zellij-org/zellij
          tree-sitter # https://github.com/tree-sitter/tree-sitter

          ###------------------------------
          ##   More Utilities
          #--------------------------------
          # These can be somewhat env specific.

          # authy
          keybase
          # puppeteer-cli # Used for mermaid -- NOTE: Broken with mesa dependency and cannot be installed
          surrealdb
          pngpaste # https://github.com/jcsalterego/pngpaste
          ollama   # https://github.com/jmorganca/ollama
          imagemagick # https://github.com/imagemagick/imagemagick

          ###------------------------------
          ##   Kubernetes
          #--------------------------------
          docker
          kubectl
          kustomize
          kubernetes-helm
          kind
          krew
          k9s
          kube3d
          kubectx
          kubeseal
          pinniped
          istioctl
          civo

          ###------------------------------
          ##   Coding
          #--------------------------------

          # Go
          go    # Needed because Vim plugin govim requires this.
          ko
          gopls

          # Rust
          # NOTE: Rust setup is either to use Nix based build setup, or rely on
          # rustup. Because when I really need to get a version controlled Rust,
          # it would be based on direnv setup, I'm using rustup as the default
          # instead. Nix setup here only handles the installation on rustup CLI
          # itself, and the rest is managed outside of Nix for simplicity.
          rustup
          # rustc
          # cargo
          # rust-analyzer

          # JS
          deno
          yarn

          # Sass
          dart-sass

          # Shell
          shellcheck  # I want this for any code base

          # Markdown
          pandoc      # Markdown support

          # C
          clang-tools

          # Protobuf
          buf

          ###------------------------------
          ##   Editors
          #--------------------------------
          # NOTE: Emacs is defined in programs section instead.
          vscode
          vscode-insiders # Added from the overlay setup

          ###------------------------------
          ##   Other UI Tools
          #--------------------------------
          discord
          slack
          zoom-us
          # rectangle # https://rectangleapp.com/ # No longer using this as I'm now using Raycast.

          ###------------------------------
          ##   Services
          #--------------------------------
          awscli
          flyctl
        ;
      }
      ###------------------------------
      ##   Python
      #--------------------------------
      ++ (with pkgs; [
        python311
        poetry    # https://python-poetry.org/
        python311.pkgs.pip
        python311.pkgs.grip # https://github.com/joeyespo/grip
        python311.pkgs.diagrams
      ])
      ###------------------------------
      ##   Node Packages
      #--------------------------------
      ++ (with pkgs.nodePackages; [
        pnpm        # https://pnpm.io/
        prettier    # https://prettier.io/
        vscode-langservers-extracted
        svelte-language-server
        mermaid-cli # https://mermaid.js.org/ -- also known as mmdc
      ])
      ###------------------------------
      ##   Dictionaries
      #--------------------------------
      ++ [
        pkgs.enchant2  # https://github.com/AbiWord/enchant
        pkgs.aspell
        pkgs.aspellDicts.en
        pkgs.aspellDicts.en-computers
        pkgs.aspellDicts.en-science
        pkgs.hunspell
        pkgs.hunspellDicts.en_GB-large
        pkgs.hunspellDicts.en_US-large
        pkgs.nuspell   # https://github.com/nuspell/nuspell
        # (pkgs.aspellWithDicts (dicts: with dicts; [
          # en
          # en-computers
          # en-science
        # ]))
        # (pkgs.hunspellWithDicts (with pkgs.hunspellDicts; [
        #   en_GB-large
        #   en_US
        # ]))
      ]
      ###------------------------------
      ##   JetBrains Related
      #--------------------------------
      ++ [
        # pkgs.jetbrains.idea-ultimate
        # pkgs.jetbrains.idea-community
      ]
      ###------------------------------
      ##   GCP
      #--------------------------------
      # Ref: https://github.com/NixOS/nixpkgs/issues/99280
      # TODO: Consider removing this from Home Manager, it is quite annoying
      # how slow it is to fetch the source.
      ++ [
        (with pkgs.google-cloud-sdk;
          withExtraComponents ([ components.gke-gcloud-auth-plugin ])
        )
      ]
      ###------------------------------
      ##   Other
      #--------------------------------
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

  launchd.agents = {
    ollama = {
      enable = true;
      config = {
        ProgramArguments = [
          "${pkgs.ollama}/bin/ollama"
          "serve"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        WorkingDirectory = "/tmp/";
      };
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
    nushell = import ../../common-config/home-manager/nushell.nix { inherit pkgs; };

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
      enableNushellIntegration = true;
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

      "enchant/enchant.ordering".source = ../../common-config/enchant.ordering;

      "git".source = ../../common-config/git;
      "git".recursive = true;

      "kind".source = ./kind-config;
      "kind".recursive = true;

      # Providing the below config via programs.tmux instead.
      # "tmux/tmux.conf".source        = ../../common-config/tmux/tmux.conf;
      "tmux/keybindings.conf".source = ../../common-config/tmux/keybindings.conf;
      "tmux/options.conf".source     = ../../common-config/tmux/options.conf;
      # "tmux/tpm.conf".source         = ../../common-config/tmux/tpm.conf;

      "yabai/yabairc".source = ./yabairc;
      # ZSH abbreviation with https://github.com/olets/zsh-abbr needs a
      # dedicated configuration file.
      "zsh-abbr/user-abbreviations".source = ../../common-config/zsh/zsh-abbr.txt;
    };
    # dataFile = {
    #   "hunspell/some_dict".source = some_file; # TODO: If I were to pull in like this, I need to sort this out.
    # };
  };
}
