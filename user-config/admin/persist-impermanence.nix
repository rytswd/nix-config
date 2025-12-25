# Impermanence based persisting file setting for files and directories.
# Only import when impermanence is used.
{
  home.persistence."/nix/persist/home/admin" = {
    allowOther = true;
    directories = [
      ".ssh"
    ];
    files = [
      # To be updated
    ];
  };
}
