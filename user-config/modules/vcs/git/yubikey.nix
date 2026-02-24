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

  private-repo = (toString inputs.nix-config-private);

  # The mutable file Git reads
  statusFile = "${config.xdg.configHome}/git/yubikey-status";

  gitWithYubikeyScript = pkgs.writeShellScriptBin "git-signing-yubikey" ''
    PATH=$PATH:${
      lib.makeBinPath [
        pkgs.git
        pkgs.yubikey-manager
        pkgs.gnupg
        pkgs.coreutils
      ]
    }

    # Priority 1: Try GPG (preferred - has TTL cache, less frequent touch)
    if command -v gpg >/dev/null 2>&1; then
      # Check if YubiKey with GPG keys is connected AND the signing key is imported
      if gpg --card-status >/dev/null 2>&1; then
        # Verify the signing key is actually available in the local keyring
        if gpg --list-secret-keys "${allKeys.gpg-key-id}" >/dev/null 2>&1; then
          echo "GPG YubiKey detected with imported keys. Using GPG for signing."
          git config -f "${statusFile}" user.signingKey "${allKeys.gpg-key-id}"
          exit 0
        else
          echo "GPG card detected but signing key ${allKeys.gpg-key-id} not in keyring."
          echo "Import your public key first with: gpg --card-edit -> fetch"
        fi
      fi
    fi

    # Priority 2: Fallback to YubiKey FIDO2 SSH (for brand new machines)
    SERIAL=$(ykman list --serials 2>/dev/null | head -n1)

    if [ -n "$SERIAL" ]; then
      KEY_PATH="${config.home.homeDirectory}/.ssh/id_yubikey_''${SERIAL}_sign.pub"

      if [ -f "$KEY_PATH" ]; then
        echo "YubiKey FIDO2 SSH detected (serial: $SERIAL). Using SSH for signing."
        git config -f "${statusFile}" user.signingKey "$KEY_PATH"
        git config -f "${statusFile}" gpg.format "ssh"
        exit 0
      fi
    fi

    # No signing method available
    echo "No GPG or YubiKey SSH signing method available. Clearing config."
    truncate -s 0 "${statusFile}"
  '';
in
{
  options = {
    vcs.git.yubikey.enable = lib.mkEnableOption "Enable Git setup using YubiKey.";
  };

  config =
    lib.mkIf (config.vcs.git.enable && config.vcs.git.yubikey.enable && config.security.sops-nix.enable)
      {
        # Set up directory structure for the rest.
        home.activation.ensureGitDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$(dirname "${statusFile}")"
          touch "${statusFile}"
        '';

        # Configure public key details in git directory.
        home.file = lib.mapAttrs' (serial: data: {
          name = ".ssh/id_yubikey_${serial}_sign.pub";
          value = {
            text = data.sign.publicKey;
          };
        }) keys;

        # This places the file in ~/.ssh/id_yubikey_<SERIAL> with 600 permissions.
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

        # Configure Git to include the dynamic status file.
        programs.git.includes = [
          { path = statusFile; }
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          # Priority: GPG-based SSH auth (first), then FIDO2 SSH keys (fallback)
          matchBlocks = {
            "github.com" = {
              user = "git";
              # Try GPG-based SSH first (shares cache with GPG signing), then FIDO2 SSH keys
              identityFile =
                # Note: GPG-based SSH keys are managed by gpg-agent via enableSshSupport
                # The agent automatically provides the key when available. We list the
                # FIDO2 resident keys as fallback when GPG is not set up.
                lib.mapAttrsToList (serial: _:
                  "${config.home.homeDirectory}/.ssh/id_yubikey_${serial}_auth"
                ) keys;
            };
            # Add gitlab or others if needed

            # Suppress warnings from trying multiple keys
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
            Description = "Dynamic Git Signing Config (GPG or YubiKey SSH)";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${gitWithYubikeyScript}/bin/git-signing-yubikey";
          };
        };
      };
}
