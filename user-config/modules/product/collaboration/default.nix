# Vendor chat / video-conf desktop clients. Importing the bundle gives me
# the full collaboration kit on any host. Each leaf is still usable on its
# own — hosts that want only one or two clients can import the leaf(s)
# directly instead of the bundle.
{
  imports = [
    ./discord.nix
    ./signal.nix
    ./slack.nix
    ./telegram.nix
    ./zoom.nix
  ];
}
