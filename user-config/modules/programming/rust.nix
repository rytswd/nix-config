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
      # rustup. Because when I really need to get a version controlled Rust,
      # it would be based on direnv setup, I'm using rustup as the default
      # instead. Nix setup here only handles the installation on rustup CLI
      # itself, and the rest is managed outside of Nix for simplicity.
      # For rust-analyzer, I needed to run the following:
      #   `rustup component add rust-analyzer`
      # Not sure if this is a hard requirement, but this seems to work.
      pkgs.rustup
      # pkgs.rustc
      # pkgs.cargo
      # pkgs.rust-analyzer
    ];
  };
}
