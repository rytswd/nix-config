#!/usr/bin/env nu

###========================================
##   Workspace aware window module
#==========================================
# A similar solution is provided from waybar directly with "wlr/taskbar", but
# it is not workspace aware and lists all the processes.
# NOTE: This may be included with https://github.com/Alexays/Waybar/issues/3745.

# Icon mapping
let icons = {
  "emacs": "",
  "vivaldi-stable": "",
  "com.mitchellh.ghostty": "󰊠",
  "vesktop": "",
}
let default_icon = "󰲋"

# Workspace based window filtering
let current_workspace = (
  niri msg -j workspaces
    | from json
    | where is_active == true
    | get id
    | first)
let windows = (
  niri msg -j windows
    | from json
    | where workspace_id == $current_workspace
    # TODO: The ID is based on the order the window is created. This should be
    # based on the order of the windows in the workspace, which isn't provided
    # from niri at the moment.
    | sort-by id
    | insert icon { |x| try { $icons | get $x.app_id } catch { $default_icon } }
    | insert class { |x| if ($x.is_focused) { "focused" }})


# NOTE: I need to do some customisation if I were to support this.
# However, because the output will be solely a text field, this probably won't
# be a viable option for switching between applications.

# NOTE: The below will be needed to use as a custom module.
    # | to json -r # Raw output is needed for Waybar to pull in.
    # | jq --unbuffered --compact-output # Required for waybar jq input.
