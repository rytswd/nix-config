{ pkgs, lib, config, ... }:

let
  admin =
    if pkgs.stdenv.isDarwin then
      {
        home = "/Users/admin";
      }
    else
      {
        home = "/home/admin";
        group = "wheel";

        # For running scripts, zsh is easier as it works similarly to bash.
        shell = pkgs.bash;

        # IMPORTANT: The admin user is not a normal user.
        isSystemUser = true;

        extraGroups = [
          "input"  # For Xremap and input handling without sudo
          "uinput" # For Xremap and input handling without sudo
        ];

        # Set initial password.
        # When the `users.mutableUsers` is set, this would only apply for the new
        # user creation. User can later change the password using `passwd` command.
        initialHashedPassword = "$6$hGTdy9p9p203$8oeOAgXLzkKdo5HUkydZkEYQbWxzXgtjMsmSB76PkO6p/JWbJuJ9FhMXmhibm.XqZD58pR8hlc5EocdncS72s/"; # root
      };
in
{
  users.users.admin = admin;

  # When using impermanence, configure what directories get persisted.
  config = lib.mkIf config.core.boot.impermanence.enable {
    environment.persistence."/nix/persist" = {
      users.admin = {
        directories = [
          ".ssh"
        ];
        files = [
          # To be updated
        ];
      };
    };
  };
}
