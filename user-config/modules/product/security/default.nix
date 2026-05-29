# Vendor security products I want on every host. Sibling to
# user-config/modules/security/ which holds the open / protocol-based
# security tooling (gpg, sops, age, pass).
{
  imports = [
    ./1password.nix
    ./keybase.nix
    ./proton-pass.nix
  ];
}
