{
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
}
