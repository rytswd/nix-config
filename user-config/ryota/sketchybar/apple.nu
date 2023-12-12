#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "apple_log"

export def icon [] {
  log info "Rendering Apple icon"

  # sketchybar command requires the specific syntax to be followed. For some
  # complex scenarios, I need to set up a separate variable and pass that into
  # the command.
  (sketchybar
    --add item $name left
    --set      $name
    ###--------------------
    ##   Background
    #----------------------
    # $"background.color=($colour.overlay)"
    $"background.corner_radius=($appearance.item_background_corner_radius)"
    $"background.height=($appearance.item_background_height)"
    $"blur_radius=($appearance.item_blur_radius)"
    # background.padding_left=4
    shadow=on

    ###--------------------
    ##   Icon
    #----------------------
    icon=""
    icon.y_offset=1
    $"icon.color=($colour.subtle_black)"
    icon.padding_right=10
    icon.padding_left=10

    ###--------------------
    ##   Label
    #----------------------
    # label=""
    # label.y_offset=1
    # label.font="Hack Nerd Font:Bold:14.0"
    # $"label.color=($colour.white)"
    # label.padding_left=-11
    label.drawing=off

    ###--------------------
    ##   Misc Appearance
    #----------------------
    # N/A

    ###--------------------
    ##   Logic
    #----------------------
    # click_script=$"($env.__POPUP_CLICK_SCRIPT)"
    popup.height=35
  )
  log info "Rendering Apple icon, complete"
}
