{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.nix.enable = lib.mkEnableOption "Adjust Nix behaviours.";
  };

  config = lib.mkIf config.core.nix.enable {
    # Dynamic libraries for unpackaged programs.
    #
    # This would allow dynamic linking to work in some cases. I do not want to
    # keep this around all the time, as it kind of defeats the purpose of the
    # reproducible system with NixOS, but could be handy at times.
    programs.nix-ld = {
      enable = true;

      # Some note about the packages that use the dynamic linking by default:
      # - sass-embedded
      #   https://discourse.nixos.org/t/web-development-with-sveltekit-sass-embedded/52474
      #   https://github.com/sass/embedded-host-node/issues/334
      libraries = [
        pkgs.glibc
        pkgs.libcxx
      ];
    };
  };
}
