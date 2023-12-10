#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# TODO: Consider making this two separate functions for date and time.

export const name = "clock"

# item renders the item. Any extra logic such as updates and event subscription
# are handled in separate functions.
export def item () {
  log info $"Rendering ($name)"

  (sketchybar
    --add item $name right
    --set      $name
    ###--------------------
    ##   Background
    #----------------------
    $"background.height=($appearance.background_height)"
    background.y_offset=0
    $"background.color=($colour.glass_dark)"
    # $"background.border_color=($colour.black)"
    $"background.border_width=2"
    background.padding_right=4
    background.padding_left=4
    background.shadow.distance=1
    # $"background.shadow.color=($colour.grey)"
    $"background.corner_radius=($appearance.background_corner_radius)"
    blur_radius=3

    ###--------------------
    ##   Icon
    #----------------------
    # N/A

    ###--------------------
    ##   Label
    #----------------------
    $"label.color=($colour.cyan)"
    label.font="FiraMono Nerd Font:Thin:14.5"
    label.padding_right=10
    label.y_offset=-1

    ###--------------------
    ##   Misc Appearance
    #----------------------

    ###--------------------
    ##   Logic
    #----------------------
    update_freq=1
    script="nu ./clock.nu"
  )

  log info $"Rendering ($name), complete"
}

# main returns the current time in a given format.
def main () {
  let now = (date now | format date "%a, %-d %b, %Y / %H:%M:%S")
  sketchybar --set $name $"label=($now)"
}
