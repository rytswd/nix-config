# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  home.persistence."/nix/persist" = {
    directories = [
      { directory = ".ssh"; mode = "0700"; }
      { directory = ".gnupg"; mode = "0700"; }
      ".config"
    ];
    files = [
      # To be updated
    ];
  };
}
