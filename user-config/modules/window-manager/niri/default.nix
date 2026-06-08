# Per-host display layout lives in `./output-<hostname>.kdl` (e.g.
# `output-asus-rog-flow-z13-2025.kdl`). Adding a new host = drop a new
# file next to its siblings. Forgetting to add it -> eval fails clearly
# (`path '/nix/store/.../output-foo.kdl' does not exist`) instead of
# silently using some other host's layout.
#
# Hostname resolution: embedded HM provides `osConfig.networking.hostName`;
# standalone HM passes `hostname` via specialArgs (see flake.nix#mkHome).
{
  pkgs,
  osConfig ? null,
  hostname ? null,
  ...
}:

let
  resolvedHostname =
    if osConfig != null && osConfig ? networking then osConfig.networking.hostName
    else if hostname != null then hostname
    else throw "window-manager/niri: needs `osConfig.networking.hostName` (embedded HM) or `specialArgs.hostname` (standalone HM)";
in
{
  home.packages = [
    pkgs.xwayland-satellite

    # NOTE: A bit of hack but this allows toggling fcitx and xkb at the same
    # time. When things got stuck in a strange state, I can do:
    #
    #     fcitx5-remote -g "Main"
    #     niir msg action switch-layout 0
    #
    (pkgs.writeShellScriptBin "niri-toggle-input-method" ''
      current=$(${pkgs.fcitx5}/bin/fcitx5-remote -q)
      if [ "$current" = "Main" ]; then
        niri msg action switch-layout 1
        ${pkgs.fcitx5}/bin/fcitx5-remote -g "JP"
      else
        niri msg action switch-layout 0
        ${pkgs.fcitx5}/bin/fcitx5-remote -g "Main"
      fi
    '')
  ];
  home.shellAliases = {
    "nirimvw" = "niri msg action move-window-to-workspace";
  };

  # Because the config is quite lengthy, I'm simply mapping a file into the
  # XDG directory. All the code is generated with the Org Mode tangle.
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    # "niri/keymap.xkb".source = ./dvorak-customised-keymap.xkb;
    "niri/output.kdl".source = ./. + "/output-${resolvedHostname}.kdl";
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      # niri needs this for screen cast.
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
      };
    };
  };
}
