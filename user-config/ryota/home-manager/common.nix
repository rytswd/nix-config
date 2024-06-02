# This is my home-manager configuration, which is meant to work for both macOS
# and NixOS. Because of the subtle difference in how I use each system, there
# are some settings that are defined in a separate file for system based setup.
# This file contains the setup that is common to both macOS and NixOS.

{ config
, pkgs
, ... }:

{
  home = {
    packages =
      # Some common packages I use for any envs + users are bundled in a
      # separate file.
      import(../../../common-config/home-manager/packages.nix) { inherit pkgs; }
      ++ pkgs.lib.attrValues {
        inherit (pkgs)
          ###------------------------------
          ##   Additional Utilities
          #--------------------------------
          du-dust       # https://github.com/bootandy/dust
          bandwhich     # https://github.com/imsnif/bandwhich
          mkcert        # https://github.com/FiloSottile/mkcert
          bottom        # https://github.com/ClementTsang/bottom
          htop          # https://github.com/htop-dev/htop
          pass          # https://www.passwordstore.org/
          git-lfs       # https://github.com/git-lfs/git-lfs
          zellij        # https://github.com/zellij-org/zellij
          tree-sitter   # https://github.com/tree-sitter/tree-sitter
          atuin         # https://github.com/atuinsh/atuin
          procs         # https://github.com/dalance/procs
          erdtree       # https://github.com/solidiquis/erdtree
          git-codereview # https://golang.org/x/review/git-codereview
          git-crypt     # https://github.com/AGWA/git-crypt
          neofetch      # https://github.com/dylanaraps/neofetch
          cloc          # https://github.com/AlDanial/cloc
          dyff          # https://github.com/homeport/dyff
          hyperfine     # https://github.com/sharkdp/hyperfine
          pueue         # https://github.com/Nukesor/pueue
          btop          # https://github.com/aristocratos/btop

          ###------------------------------
          ##   More Utilities
          #--------------------------------
          # These can be somewhat env specific.

          keybase       # https://keybase.io/
          surrealdb     # https://surrealdb.com/
          graphviz      # https://graphviz.org/
          ollama        # https://github.com/jmorganca/ollama
          imagemagick   # https://github.com/imagemagick/imagemagick
          librsvg       # https://wiki.gnome.org/Projects/LibRsvg

          ###------------------------------
          ##   Email
          #--------------------------------
          mu
          isync
          msmtp

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
          cilium-cli
          hubble
          talosctl
          vcluster

          ###------------------------------
          ##   Coding
          #--------------------------------
          # Many coding dependencies are better handled per project / directory,
          # but here are some common ones I would always want to keep in my PATH
          # for convenience, or I need to have in PATH due to existing setup
          # expect such tools to be available.

          # Go
          go            # Needed because Vim plugin govim requires this.
          ko
          gopls
          templ

          # Rust
          # NOTE: Rust setup is either to use Nix based build setup, or rely on
          # rustup. Because when I really need to get a version controlled Rust,
          # it would be based on direnv setup, I'm using rustup as the default
          # instead. Nix setup here only handles the installation on rustup CLI
          # itself, and the rest is managed outside of Nix for simplicity.
          # For rust-analyzer, I needed to run the following:
          #   `rustup component add rust-analyzer`
          # Not sure if this is a hard requirement, but this seems to work.
          rustup
          # rustc
          # cargo
          # rust-analyzer

          # JS
          bun
          deno
          yarn

          # Sass
          dart-sass

          # HTML
          emmet-language-server

          # Shell
          shellcheck    # I want this for any code base

          # Markdown
          pandoc        # Markdown support

          # C
          clang-tools

          # Protobuf
          buf

          # Java
          jdk

          ###------------------------------
          ##   Editors
          #--------------------------------
          # Emacs is configured at programs.emacs
          # TODO: Add another Emacs so that I can test multiple Emacs builds.
          # NeoVim is configured at programs.neovim.
          # Helix is configured at programs.helix.
          # VSCode is configured at programs.vscode.

          ###------------------------------
          ##   Services
          #--------------------------------
          awscli
          civo
          flyctl
        ;
      }
      ###------------------------------
      ##   Python
      #--------------------------------
      ++ [
        (pkgs.python311.withPackages (ps: with ps; [
          pyyaml
          pandas
        ]))
        pkgs.poetry    # https://python-poetry.org/
        pkgs.python311.pkgs.pip
        # pkgs.python311.pkgs.grip # https://github.com/joeyespo/grip
        pkgs.python-grip # Overlay in place for the above to get the latest master.
        pkgs.python311.pkgs.diagrams
      ]
      ###------------------------------
      ##   Zig
      #--------------------------------
      ++ [
        # pkgs.zig
        pkgs.zigpkgs.master # NOTE: Based on https://github.com/mitchellh/zig-overlay
        pkgs.zls
      ]
      ###------------------------------
      ##   Roc
      #--------------------------------
      ++ [
        pkgs.rocpkgs.cli
      ]
      ###------------------------------
      ##   Node Packages
      #--------------------------------
      ++ [
        # Because of @ symbol being a part of the package name for some node
        # packages, I have to use the full path and cannot use "with pkgs;"
        # setup
        pkgs.nodePackages.pnpm        # https://pnpm.io/
        pkgs.nodePackages.prettier    # https://prettier.io/
        pkgs.nodePackages.typescript # Needed for the language server

        # Language Servers
        pkgs.nodePackages.typescript-language-server
        pkgs.nodePackages.vscode-langservers-extracted
        pkgs.nodePackages.svelte-language-server
        pkgs.nodePackages."@astrojs/language-server"

        # NOTE: mermaid-cli has a runtime dependency against puppeteer, which in
        # turn requires chromium binary to be made available. As I couldn't sort
        # out Chromium installation via Nix, I'm currently using Homebrew Cask
        # to install Chromium.
        pkgs.nodePackages.mermaid-cli # https://mermaid.js.org/ -- also known as mmdc
      ]
      ###------------------------------
      ##   Dictionaries
      #--------------------------------
      ++ [
        pkgs.enchant2  # https://github.com/AbiWord/enchant
        # http://aspell.net/
        # aspell setup takes a function argument.
        (with pkgs; aspellWithDicts (dicts: with dicts; [
          aspellDicts.en
          aspellDicts.en-computers
          aspellDicts.en-science
        ]))
        # https://github.com/hunspell/hunspell
        # hunspell setup takes a list argument.
        (with pkgs; hunspellWithDicts [
          hunspellDicts.en_GB-large
          hunspellDicts.en_US-large
        ])
        # https://github.com/nuspell/nuspell
        # nuspell uses the same dictionary as hunspell.
        (with pkgs; nuspellWithDicts [
          hunspellDicts.en_GB-large
          hunspellDicts.en_US-large
        ])
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
        # (import ../../../overlays/mirrord.nix { inherit pkgs; }) # mirrord isn't available in nixpkgs
      ]
    ;

    # Any aliases defined here will be concatanated with the aliases defined in
    # shell specific setup. If there is a conflict, it would result in an error.
    shellAliases =
      (import ../../../common-config/home-manager/aliases-basic.nix) //
      {
        # Any aliases defined here will override the ones defined prior to this.
        k = "kubectl";
        gccact = "gcloud config configurations activate";
        gccls = "gcloud config configurations list";
      };

    # Environment variables
    sessionVariables = {
      # Although I use Emacs for my main driver, I want to ensure that this
      # editor choice works in any environment, even when Emacs server is not
      # running. I could use `emacs -nw`, but for now, as my Emacs configuration
      # only works for GUI version, using nvim as the default makes it easy.
      EDITOR = "nvim";
      LESS = "-iMNR";
      # TODO: Add DIRENV_LOG_FORMAT to be an empty string to suppress the output

      # ripgrep
      RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";

      # fzf
      FZF_CTRL_T_OPTS="
        --preview 'bat -n --color=always {}'
        --bind 'ctrl-/:change-preview-window(down|hidden|)'";
      # alt+c: fzf based cd, which can be triggered at any time to change dir.
      FZF_ALT_C_OPTS = "--preview 'tree -C {}'";

      # kubectl
      KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";

    };
  };

  programs = {
    home-manager.enable = true;

    # + Editors

    # Emacs setup.
    # There is an overlay in place to configure how it's built. Actual Emacs
    # configurations are not managed in Nix, and is managed in a separate
    # repository as of writing. This is because I like the fast feedback loop
    # using Elpaca, and the packages installed here are those that need extra
    # steps configuring using Elpaca.
    emacs = {
      enable = true;
      package = pkgs.emacs-rytswd; # Based on overlay with extra build flags.
      extraPackages = (epkgs: with epkgs; [
        vterm
        jinx
        pdf-tools
        mu4e
        treesit-grammars.with-all-grammars
      ]);
    };

    # NeoVim isn't my daily driver, but I use it time to time. The configuration
    # is now managed by NvChad, and thus nothing is configured here. I may
    # decide to manage everything here in Nix at some point, but it is not the
    # priority for now.
    neovim = {
      enable = true;
    };
    helix = {
      enable = true;
      # Because Helix uses TOML for its configuration, I configure them separately.
    };

    vscode = {
      enable = true;
      # I'm not managing extensions via home-manager.
      # extensions = with pkgs.vscode-extensions; [
      # dracula-theme.theme-dracula
      # vscodevim.vim
      # yzhang.markdown-all-in-one
      # ];
    };


    # + Terminals
    # NOTE: As I'm using using Ghostty, I don't use neither Alacritty nor Kitty
    # these days. I'm just keeping them around for reference only when I need to
    # test against.
    alacritty = {
      enable = true;
    };
    kitty = {
      enable = true;
    };

    # + Shells
    # Because there are some nuances based on shell, and thus the actual
    # configurations are managed in separate files.
    bash = import ../../../common-config/home-manager/bash.nix { inherit pkgs; };
    fish = import ../../../common-config/home-manager/fish.nix { inherit pkgs; };
    zsh  = import ../../../common-config/home-manager/zsh.nix  { inherit pkgs; };
    nushell = import ../../../common-config/home-manager/nushell.nix { inherit pkgs; };

    # NOTE: I'm not using tmux too much as I started using Ghostty for multiple
    # terminal sessions.
    tmux = import ../../../common-config/home-manager/tmux.nix { inherit pkgs; };

    # Ensure to make direnv with nix-direnv available.
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

    # I use Yazi for most of the file navigation (along with Zoxide).
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };
    zoxide = {
      enable = true;
      # In order to call the builtin 'cd', I can use 'builtin cd'.
      options = [ "--cmd cd"];

      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
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

  # XDG Base Directory Setup
  xdg = {
    enable = true;
    configFile = {
      # Instead of using programs.starship.settings, copy the TOML file over.
      "starship.toml".source = ../../../common-config/starship.toml;

      "alacritty/alacritty.toml".source = ../alacritty.toml;

      # TODO: Move this to common config
      "bat/config".source = ../bat-config.sh;

      # Temporarily commenting out as I'm still exploring this.
      # "btop/btop.conf".source = ../../../common-config/btop/btop.conf;

      "direnv/direnv.toml".source = ../../../common-config/direnv/direnv.toml;

      # Enchant config, and pull in
      "enchant/enchant.ordering".source = ../../../common-config/enchant/enchant.ordering;

      "fd".source = ../../../common-config/fd;
      "fd".recursive = true;

      "git".source = ../../../common-config/git;
      "git".recursive = true;

      # TODO: Move this to common config
      "kind".source = ../kind-config;
      "kind".recursive = true;

      # TODO: Ghostty configs are still being worked on, and thus the config
      # is only mapped as a backup. Once all the configuration needs are clear,
      # ensure to use this as the main config.
      "ghostty/config_bak".source = ../../../common-config/ghostty/config;

      "ripgrep/config".source = ../../../common-config/ripgrep/config;

      # Providing the below config via programs.tmux instead.
      # "tmux/tmux.conf".source        = ../../../common-config/tmux/tmux.conf;
      "tmux/keybindings.conf".source = ../../../common-config/tmux/keybindings.conf;
      "tmux/options.conf".source     = ../../../common-config/tmux/options.conf;
      # "tmux/tpm.conf".source         = ../../../common-config/tmux/tpm.conf;

      "yazi".source = ../../../common-config/yazi;
      "yazi".recursive = true;

      # ZSH abbreviation with https://github.com/olets/zsh-abbr needs a
      # dedicated configuration file.
      "zsh-abbr/user-abbreviations".source = ../../../common-config/zsh/zsh-abbr.txt;
    };
    # dataFile = {
    #   "hunspell/some_dict".source = some_file; # TODO: If I were to pull in like this, I need to sort this out.
    # };
  };
}
