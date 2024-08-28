{ pkgs
, lib
, config
, ...}:

{
  options = {
    shell.util.enable = lib.mkEnableOption "Enable Shell utilities.";
  };

  config = lib.mkIf config.shell.util.enable {
    home.packages = [
      ###------------------------------
      ##   Network related
      #--------------------------------
      pkgs.bandwhich    # https://github.com/imsnif/bandwhich

      ###------------------------------
      ##   File related
      #--------------------------------
      pkgs.eza          # https://github.com/eza-community/eza
      pkgs.bat          # https://github.com/sharkdp/bat
      pkgs.ripgrep      # https://github.com/BurntSushi/ripgrep
      pkgs.fd           # https://github.com/sharkdp/fd
      pkgs.zoxide       # https://github.com/ajeetdsouza/zoxide
      pkgs.du-dust      # https://github.com/bootandy/dust
      pkgs.erdtree      # https://github.com/solidiquis/erdtree
      pkgs.delta        # https://github.com/dandavison/delta
      pkgs.cloc         # https://github.com/AlDanial/cloc

      # TODO: Consider creating programming YAML
      pkgs.dyff         # https://github.com/homeport/dyff

      # pkgs.rm-improved  # https://github.com/nivekuil/rip

      ###------------------------------
      ##   Security related
      #--------------------------------
      pkgs.mkcert       # https://github.com/FiloSottile/mkcert
      pkgs.pass         # https://www.passwordstore.org/

      ###------------------------------
      ##   Performance related
      #--------------------------------
      pkgs.btop         # https://github.com/aristocratos/btop
      pkgs.htop         # https://github.com/htop-dev/htop
      pkgs.bottom       # https://github.com/ClementTsang/bottom
      pkgs.hyperfine    # https://github.com/sharkdp/hyperfine

      ###------------------------------
      ##   Process related
      #--------------------------------
      pkgs.procs        # https://github.com/dalance/procs
      pkgs.pueue        # https://github.com/Nukesor/pueue

      ###------------------------------
      ##   Other
      #--------------------------------
      pkgs.shellcheck   # https://github.com/koalaman/shellcheck
      pkgs.zellij       # https://github.com/zellij-org/zellij
      pkgs.atuin        # https://github.com/atuinsh/atuin
      pkgs.neofetch     # https://github.com/dylanaraps/neofetch

      # pkgs.sd           # https://github.com/chmln/sd
    ];

    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };

      # I use Yazi for most of the file navigation (along with Zoxide).
      # Yazi definitions are in a separate file as it needs more tweaking.

      # Atuin is also enabled, but handled separately in a module.

      zoxide = {
        enable = true;
        # In order to call the builtin 'cd', I can use 'builtin cd'.
        options = [ "--cmd cd"];

        enableBashIntegration = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
      };
    };

    xdg.configFile = {
      "bat/config".source = ./bat/bat-config.sh;

      # Temporarily commenting out as I'm still exploring this.
      # "btop/btop.conf".source = ./btop/btop.conf;

      "fd".source = ./fd;
      "fd".recursive = true;

      "ripgrep/config".source = ./ripgrep/ripgrep-conf.sh;
    };
  };
}
