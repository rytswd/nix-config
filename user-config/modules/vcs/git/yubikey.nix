{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  allKeys = import "${inputs.self}/shared/keys.nix";

  keys = lib.mapAttrs (_: k: {
    auth.publicKey = k.auth;
    sign.publicKey = k.sign;
  }) allKeys.yubikey;

  private-repo = (builtins.toString inputs.nix-config-private);

  # The mutable file Git reads
  statusFile = "${config.xdg.configHome}/git/yubikey-status";

  ykUpdateScript = pkgs.writeShellScriptBin "yk-update-git" ''
    PATH=$PATH:${
      lib.makeBinPath [
        pkgs.git
        pkgs.yubikey-manager
        pkgs.coreutils
      ]
    }

    SERIAL=$(ykman list --serials 2>/dev/null | head -n1)

    if [ -z "$SERIAL" ]; then
      echo "No YubiKey detected. Clearing Git signing config."
      truncate -s 0 "${statusFile}"
      exit 0
    fi

    # TARGET: We look for the key in ~/.ssh because that is where the private key lives
    KEY_PATH="${config.home.homeDirectory}/.ssh/id_yubikey_''${SERIAL}_sign.pub"

    if [ -f "$KEY_PATH" ]; then
      echo "Applying config for YubiKey $SERIAL"

      # IMPORTANT: user.signingKey points to the .pub file in ~/.ssh
      git config -f "${statusFile}" user.signingKey "$KEY_PATH"
      git config -f "${statusFile}" gpg.format "ssh"
    else
      echo "YubiKey $SERIAL found, but key file missing at $KEY_PATH"
      truncate -s 0 "${statusFile}"
    fi
  '';
in
{
  options = {
    vcs.git.yubikey.enable = lib.mkEnableOption "Enable Git setup using YubiKey.";
  };

  config =
    lib.mkIf (config.vcs.git.enable && config.vcs.git.yubikey.enable && config.security.sops-nix.enable)
      {
        # 1. Setup Directory Structure
        home.activation.ensureGitDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$(dirname "${statusFile}")"
          touch "${statusFile}"
        '';

        # Configure public key details in git directory
        home.file = lib.mapAttrs' (serial: data: {
          name = ".ssh/id_yubikey_${serial}_sign.pub";
          value = {
            text = data.sign.publicKey;
          };
        }) keys;
        # 3. Deploy Private Stubs (Encrypted via SOPS)
        # This places the file in ~/.ssh/id_yubikey_<SERIAL> with 600 permissions
        sops.secrets = lib.mkMerge (lib.mapAttrsToList (serial: data: {
          "yubikey_stub_${serial}/auth" = {
            sopsFile = "${private-repo}/keys/ssh/yubikey-stub.yaml";
            path = "${config.home.homeDirectory}/.ssh/id_yubikey_${serial}_auth";
            mode = "0600";
          };
          "yubikey_stub_${serial}/sign" = {
            sopsFile = "${private-repo}/keys/ssh/yubikey-stub.yaml";
            path = "${config.home.homeDirectory}/.ssh/id_yubikey_${serial}_sign";
            mode = "0600";
          };
        }) keys);

        # 2. Configure Git to include the dynamic status file
        programs.git.includes = [
          { path = statusFile; }
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          # We explicitly tell SSH to use the AUTH key, not the signing key
          matchBlocks = {
            "github.com" = {
              user = "git";
              # Dynamically add all auth keys as valid identities
              identityFile = lib.mapAttrsToList (serial: _:
            "${config.home.homeDirectory}/.ssh/id_yubikey_${serial}_auth"
              ) keys;
            };
            # Add gitlab or others if needed

            # Suppress warnings from trying to use all YubiKeys.
            "*" = {
              extraOptions = {
                LogLevel = "ERROR";
              };
            };
          };
        };

        # The Systemd Service (Triggered by Udev)
        systemd.user.services.yk-git-update = {
          Unit = {
            Description = "Dynamic Git Config from YubiKey Serial";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${ykUpdateScript}/bin/yk-update-git";
          };
        };
      };
}
