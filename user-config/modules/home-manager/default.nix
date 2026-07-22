{ self, ... }:
{
  imports = [
    ./bootstrap.nix
    # bootstrap.nix references `config.local.repoPath` (declared in
    # lib/paths.nix). Every home profile pulls in this bundle, so declare the
    # `local.*` options here rather than relying on an unrelated module to drag
    # paths.nix in (the appearance/noctalia module used to, which silently broke
    # the `admin` profile when that import was dropped). Imported via the same
    # `${self}` path the profiles use, so the module system deduplicates it.
    "${self}/user-config/modules/lib/paths.nix"
  ];
}
