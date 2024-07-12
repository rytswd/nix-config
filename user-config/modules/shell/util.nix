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
      pkgs.du-dust      # https://github.com/bootandy/dust
      pkgs.erdtree      # https://github.com/solidiquis/erdtree
      pkgs.cloc         # https://github.com/AlDanial/cloc
      pkgs.dyff         # https://github.com/homeport/dyff

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
      pkgs.zellij       # https://github.com/zellij-org/zellij
      pkgs.atuin        # https://github.com/atuinsh/atuin
      pkgs.neofetch     # https://github.com/dylanaraps/neofetch

      pkgs.tree-sitter # https://github.com/tree-sitter/tree-sitter
    ];
  };
}
