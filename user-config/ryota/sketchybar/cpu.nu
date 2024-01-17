#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
# export const name = "input"
export const name = "Stats,CPU_mini"

# TODO: Consider creating a separate input setup -- the original icon is quite ugly

export def item [] {
  log info "Rendering cpu -- using alias"

  # sketchybar command requires the specific syntax to be followed. For some
  # complex scenarios, I need to set up a separate variable and pass that into
  # the command.

  (sketchybar
    --add alias $name right
    --set       $name
    ###--------------------
    ##   Background
    #----------------------
    # $"background.color=($colour.green)"
    # $"background.corner_radius=($appearance.item_background_corner_radius)"
    # $"background.height=($appearance.item_background_height)"
    # $"blur_radius=($appearance.item_blur_radius)"
    # $"background.padding_left=4"
    # $"background.padding_right=-5"
    # shadow=on

    ###--------------------
    ##   Icon
    #----------------------
    # $"icon.drawing=off"

    ###--------------------
    ##   Label
    #----------------------
    # $"label.drawing=off"
    # $"label.padding_right=-20"

    ###--------------------
    ##   Misc Appearance
    #----------------------
    # N/A

    ###--------------------
    ##   Logic
    #----------------------
    # click_script=$"($env.__POPUP_CLICK_SCRIPT)"
    # popup.height=35
  )

  log info "Rendering cpu, complete"
}
