{ pkgs
, lib
, config
, ...}:

{
  options = {
    programming.rust.enable = lib.mkEnableOption "Enable Rust development related tools.";
  };

  config = lib.mkIf config.programming.rust.enable {
    home.packages = [
      # NOTE: Rust setup is either to use Nix based build setup, or rely on
      # rustup. When I really need to get a version controlled Rust,
      # I would use direnv based setup. For that reason, rustup is the default
      # setup I have. Nix setup here only handles the installation on rustup
      # CLI itself, and the rest is managed outside of Nix for simplicity.
      #
      # For rust-analyzer, I needed to run the following:
      #
      #   `rustup component add rust-analyzer`
      #
      pkgs.rustup
      # pkgs.rustc
      # pkgs.cargo
      # pkgs.rust-analyzer

      pkgs.rust-script
    ];
    home.sessionPath = [
      "$HOME/.cargo/bin"
    ];
  };
}
