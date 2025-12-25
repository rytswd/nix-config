# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  home.persistence."/nix/persist" = {
    allowOther = true;
    directories = [
      ".ssh"
    ];
    files = [
      # To be updated
    ];
  };
}
