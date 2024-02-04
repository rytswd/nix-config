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
          git-codereview # https://golang.org/x/review/git-codereview
          git-crypt     # https://github.com/AGWA/git-crypt
          neofetch      # https://github.com/dylanaraps/neofetch
          cloc          # https://github.com/AlDanial/cloc
          dyff          # https://github.com/homeport/dyff
          hyperfine     # https://github.com/sharkdp/hyperfine

          ###------------------------------
          ##   More Utilities
          #--------------------------------
          # These can be somewhat env specific.

          # authy
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

          # Zig
          zig
          zls
          # zig_0_12

          # JS
          bun
          deno
          yarn

          # Sass
          dart-sass

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
          # Emacs is configured at programs.emacs.
          # emacs-macport-rytswd  # Custom definition from overlay.

          # NeoVim is configured at programs.neovim.
          # Helix is configured at programs.helix.

          # vscode
          # vscode-insiders   # Added from the overlay setup

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
        pkgs.python311.pkgs.grip # https://github.com/joeyespo/grip
        pkgs.python311.pkgs.diagrams
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

        # Language Servers
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
        (import ../../../common-config/overlays/erdtree.nix { inherit (pkgs) lib rustPlatform fetchFromGitHub; }) # Install erdtree directly
        # (import ../../../common-config/overlays/mirrord.nix { inherit pkgs; }) # mirrord isn't available in nixpkgs
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

      RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";
      KUBECTL_EXTERNAL_DIFF = "dyff between --omit-header --set-exit-code";
    };
  };

  programs = {
    home-manager.enable = true;

    # Emacs setup.
    # There is an overlay in place to configure how it's built. Actual Emacs
    # configurations are not managed in Nix, and is managed in a separate
    # repository as of writing. (I may decide to change that at some point.)
    emacs = {
      enable = true;
      package = if pkgs.stdenv.isDarwin
                                then pkgs.emacs-plus-rytswd # Based on overlay
                                else pkgs.emacs; # TODO: I need to configure this correctly.
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

  # XDG Base Directory Setup
  xdg = {
    enable = true;
    configFile = {
      # Instead of using programs.starship.settings, copy the TOML file over.
      "starship.toml".source = ../../../common-config/starship.toml;

      # TODO: use toml instead
      "alacritty/alacritty.yml".source = ../alacritty.yaml;

      # TODO: Move this to common config
      "bat/config".source = ../bat-config.sh;

      "enchant/enchant.ordering".source = ../../../common-config/enchant.ordering;

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
