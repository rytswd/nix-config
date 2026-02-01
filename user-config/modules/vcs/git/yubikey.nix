{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  # Keys are generated with commands like:
  #
  #   ssh-keygen -t ed25519-sk -O resident -C "YubiKey Auth Nano C"
  #
  # Define my keys here (Serial -> Secret Name mapping)
  keys = {
    "28656036" = {
      auth.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIey7k133RLvHWG7AybBxK8la06QCKw5OGoxvi0IWqUaAAAACHNzaDpBdXRo yubikey-28656036-auth";
      sign.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDwOp5Hi95SJV+MzrwPXx+9si4DtKHPjjEVnCcfxxpimAAAADnNzaDpHaXRTaWduaW5n yubikey-28656036-signing";
    };
    "28656210" = {
      auth.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDjsRp17ZN3bBNsJzsS1UmXmztxnPChAIuM2sB8X47jvAAAACHNzaDpBdXRo yubikey-28656210-auth";
      sign.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINY7AcCZ8fpomi8xCrBzNuwOPrBVE+HNTXOdNqDzyuFZAAAADnNzaDpHaXRTaWduaW5n yubikey-28656210-signing";
    };
    "32149556" = {
      auth.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIObcjrmJ0U0y2K4WSTNP3s4iO3G+Jz4YmfiUPac++lMeAAAACHNzaDpBdXRo yubikey-32149556-auth";
      sign.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAcE4QrxQL58es6zCr/GxfGyzGgF5ykpan+mq+DlvK7MAAAADnNzaDpHaXRTaWduaW5n yubikey-32149556-signing";
    };
    "33200429" = {
      auth.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKb8IpultzzxnlcmL+DxNXNxMFWUBwIuyIiSY0EVwiRlAAAACHNzaDpBdXRo yubikey-33200429-auth";
      sign.publicKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN08ypm/Dc7Ue6P3j25m0RdSavisMvUA6U7o+a0wAaEQAAAADnNzaDpHaXRTaWduaW5n yubikey-33200429-signing";
    };
    # Add backup keys here...
  };

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
