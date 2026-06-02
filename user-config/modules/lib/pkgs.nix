# Shared package-handling helpers.
#
# Home Manager modules that need to install packages whose nixpkgs coverage
# varies by platform (e.g. `zoom-us` is x86_64-linux only, `signal-desktop`
# is spotty on aarch64-linux) should use `config.local.availablePackages`
# instead of hand-rolling `lib.optionals (lib.meta.availableOn ...) [ pkgs.X ]`
# at every call site.
#
# Typical use:
#
#     { config, pkgs, ... }:
#     {
#       home.packages = config.local.availablePackages [
#         pkgs.zoom-us
#         pkgs.slack
#       ];
#     }
#
# Packages that aren't buildable on the current `pkgs.stdenv.hostPlatform`
# are silently dropped from the resulting list — no eval failure.
{ lib, pkgs, ... }:
{
  options.local.availablePackages = lib.mkOption {
    type = lib.types.functionTo (lib.types.listOf lib.types.package);
    readOnly = true;
    default =
      packageList:
      lib.filter (p: lib.meta.availableOn pkgs.stdenv.hostPlatform p) packageList;
    defaultText = lib.literalExpression ''
      packageList:
        lib.filter (p: lib.meta.availableOn pkgs.stdenv.hostPlatform p) packageList
    '';
    description = ''
      Filter a list of packages to only those buildable on this host's
      platform (`pkgs.stdenv.hostPlatform`). Use in `home.packages` (or
      `environment.systemPackages`) to gracefully skip packages whose
      nixpkgs coverage doesn't include the current architecture, instead
      of having to wrap each entry in
      `lib.optionals (lib.meta.availableOn ...) [ pkgs.X ]`.
    '';
  };
}
