# All WM leaves (hyprland / niri / yabai) are opt-in. Hosts that want a WM
# import the relevant leaf directly. The bundle is empty by design — hosts
# can keep the uniform `./window-manager` import line, and the per-WM
# `./hyprland`, `./niri`, `./yabai` paths stay stable.
#
# Note that ./niri still declares its own `window-manager.niri.outputConfig`
# option (path tunable), and ./niri's `enable` flag is preserved by that
# module — set `window-manager.niri.enable = true;` from the host config.
{ }
