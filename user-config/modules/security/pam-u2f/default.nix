# PAM (Pluggable Authentication Module) integrating U2F (Universal 2nd Factor).
{
  xdg.configFile = {
    "Yubico/u2f_keys".source = ./u2f-keys.txt;
  };
}
