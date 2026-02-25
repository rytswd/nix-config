{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.rytswd.services.fix-webcam-resume;
in
{
  options.rytswd.services.fix-webcam-resume = {
    pciAddress = lib.mkOption {
      type = lib.types.str;
      # This can be retrieved with something like
      #
      #     readlink /sys/bus/usb/devices/usb1 | grep -oP 'pci[^/]+/\K[0-9a-f:.]+(?=/)'
      example = "0000:00:8.1";
      description = "PCI address of the xHCI controller to reset after resume.";
    };
  };

  config = {
    systemd.services.fix-webcam-resume = {
      description = "Reset USB controller for webcam after resume";
      # NOTE: I'm only making this service available to be kicked off manually.
      # after = [ "suspend.target" ];
      # wantedBy = [ "suspend.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "fix-webcam" ''
            echo "${cfg.pciAddress}" > /sys/bus/pci/drivers/xhci_hcd/unbind
            sleep 1
            echo "${cfg.pciAddress}" > /sys/bus/pci/drivers/xhci_hcd/bind
          ''
        );
      };
    };
  };
}
