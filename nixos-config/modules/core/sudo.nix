{ pkgs
, lib
, config
, ...}:

{
  options = {
    core.sudo.enable = lib.mkEnableOption "Enable sudo settings.";
  };

  config = lib.mkIf config.core.sudo.enable {
    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands = builtins.map
            (command: { command = "${command}"; options = ["NOPASSWD"]; })
            [
              "/run/current-system/sw/bin/nixos-rebuild"
              # "xremap"
            ];
          groups = ["Wheel"];
        }
      ];
    };
  };
}
