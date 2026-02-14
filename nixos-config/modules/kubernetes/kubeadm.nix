{ pkgs
, lib
, config
, ...}:

let
  cfg = config.kubernetes.kubeadm;
  version = config.kubernetes.common.version;

  kubeadm = pkgs.stdenv.mkDerivation {
    pname = "kubeadm";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubeadm";
      hash = "sha256-in/zRO7xv7qI+adLP9yepESMlPGzzvuMCu6vH5bgUFM=";
    };
    dontUnpack = true;
    installPhase = ''
      install -Dm755 $src $out/bin/kubeadm
    '';
  };

  kubectl = pkgs.stdenv.mkDerivation {
    pname = "kubectl";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://dl.k8s.io/release/v${version}/bin/linux/amd64/kubectl";
      hash = "sha256-NuL0rGYlkjI0HdeGaVLWSpWIRkcPappqgTuRF72WUgc=";
    };
    dontUnpack = true;
    installPhase = ''
      install -Dm755 $src $out/bin/kubectl
    '';
  };
in
{
  options = {
    kubernetes.kubeadm.enable = lib.mkEnableOption "Enable kubeadm and kubectl.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ kubeadm kubectl ];

    # kubeadm needs these directories to exist.
    systemd.tmpfiles.rules = [
      "d /etc/kubernetes 0755 root root -"
      "d /etc/kubernetes/manifests 0755 root root -"
      "d /etc/kubernetes/pki 0700 root root -"
    ];

    # Shell completion for kubectl.
    programs.bash.interactiveShellInit = ''
      source <(${kubectl}/bin/kubectl completion bash)
    '';
  };
}
