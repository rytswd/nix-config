# macOS provides pbcopy/pbpaste natively, so only the cross-platform clipse
# manager is needed.
{ ... }:
{
  imports = [ ./clipse ];
}
