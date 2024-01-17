# This is my home-manager configuration, which is meant to work for both macOS
# and NixOS. Because of the subtle difference in how I use each system, there
# are some settings that are defined in a separate file for system based setup.

{ pkgs
, ghostty
, username
, ... }:

{
  # TODO: Work around for build error relating to 'mistune.renderers' has no attribute 'BaseRenderer'.
  # manual.manpages.enable = false;

  imports = [
    (if pkgs.stdenv.isDarwin then ./macos.nix else ./nixos.nix)
  ];

  home = {
    stateVersion = "23.11";

    packages =
      # Some common packages I use for any envs are bundled in a separate file.
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

          ###------------------------------
          ##   More Utilities
          #--------------------------------
          # These can be somewhat env specific.

          # authy
          keybase       # https://keybase.io/
          # surrealdb     # https://surrealdb.com/
          # graphviz      # https://graphviz.org/
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
          # templ # FIXME This should be commented in, only commented out for NixOS testing

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

          # Zig
          zig
          zls
          # zig_0_12

          # JS
          deno
          yarn

          # Sass
          # dart-sass # TODO: This is not compiling at the moment

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
          flyctl
          civo
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
      ##   Ghostty
      #--------------------------------
      # Because it's managed in a private repository for now, adding this as a
      # separate entry.
      # NOTE: Ghostty cannot be built using Nix only, and it's built using xcode
      # in the officual build. For now, I'm sticking to that instead.
      # ++ [
      #   ghostty.packages.aarch64-darwin.default
      # ]
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
    };
  };

  programs = {
    home-manager.enable = true;

    emacs = {
      enable = true;
      package = if pkgs.stdenv.isDarwin
                                then pkgs.emacs-plus-rytswd # Based on overlay
                                else pkgs.emacs; # TODO: I need to configure this correctly.
    };

    # I don't use too much of vim, but making it available for some use cases.
    # Most of the configs were taken from @micnncim 🥰
    neovim = {
      enable = true;
      # NOTE: Commenting out the below setup, as I'm testing out NvChad for now.
      # plugins = with pkgs; [
      #   vimPlugins.copilot-vim
      #   vimPlugins.nord-nvim
      #   vimPlugins.nvim-treesitter
      #   vimPlugins.nvim-treesitter-textobjects
      #   vimPlugins.vim-markdown
      #   {
      #     plugin = vimPlugins.hop-nvim;
      #     type = "lua";
      #     config = ''
      #       require("hop").setup { keys = 'uhetonas' } -- Dvorak
      #       nmap("<Leader>w", ":HopWord<CR>")
      #       nmap("<Leader>l", ":HopLine<CR>")
      #       nmap("<Leader>s", ":HopChar1<CR>")
      #     '';
      #   }
      #   {
      #     plugin = vimPlugins.nvim-surround;
      #     type = "lua";
      #     config = ''
      #       require("nvim-surround").setup()
      #     '';
      #   }
      # ];
      # extraConfig = ''
      #   colorscheme nord

      #   set number

      #   nnoremap <Space> <Nop>
      #   let g:mapleader = "\<Space>"
      # '';
      # extraLuaConfig = ''
      #   local function nmap(shortcut, command, opts)
      #     vim.keymap.set("n", shortcut, command, opts or { noremap = true, silent = true })
      #   end
      # '';
    };
    helix = {
      enable = true;

      # Because Helix uses TOML for its configuration, I configure them in the
    };

    # + Terminals
    # NOTE: I don't use neither Alacritty nor Kitty these days, but keeping them
    # around just for reference and when I need to test against.
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

    tmux = import ../../../common-config/home-manager/tmux.nix { inherit pkgs; };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    yazi = {
      enable = pkgs.stdenv.isDarwin; # Temporarily disable for NixOS
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
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
      "starship.toml".source = ../../../common-config/starship.toml;

      # TODO: use toml instead
      # "alacritty/alacritty.yml".source = ../alacritty.yaml;

      # TODO: Move this to common config
      # "bat/config".source = ../bat-config.sh;

      "enchant/enchant.ordering".source = ../../../common-config/enchant.ordering;

      "git".source = ../../../common-config/git;
      "git".recursive = true;

      # TODO: Move this to common config
      # "kind".source = ../kind-config;
      # "kind".recursive = true;

      # TODO: Ghostty configs are still being worked on, and thus the config
      # is only mapped as a backup. Once all the configuration needs are clear,
      # ensure to use this as the main config.
      "ghostty/config_bak".source = ../../../common-config/ghostty/config;

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
