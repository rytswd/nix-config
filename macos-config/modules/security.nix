# macOS security baseline.
{ ... }:
{
  security = {
    # TouchID for sudo authentication. Falls back to password if no
    # finger is enrolled.
    # TODO: I'm not sure if this needs a separate module like this. There could
    # be a dedicated module for MBP specific configuration all bundled together
    # rather than making sometihng explicit like this.
    pam.services.sudo_local.touchIdAuth = true;
  };
}
