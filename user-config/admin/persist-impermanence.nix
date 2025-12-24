# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
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
}
