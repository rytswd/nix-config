# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  home.persistence."/nix/persist" = {
    directories = [
      ".ssh"
      ".config"
    ];
    files = [
      # To be updated
    ];
  };
}
