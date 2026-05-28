{
  # Ensure password can be changed with `passwd`.
  users.mutableUsers = true;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;
}
