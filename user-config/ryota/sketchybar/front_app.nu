#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "front_app"

# item renders the item. Any extra logic such as updates and event subscription
# are handled in separate functions.
export def item () {
  log info $"Rendering ($name)"

  (sketchybar
    --add item $name left
    --set      $name
    ###--------------------
    ##   Background
    #----------------------
    $"background.height=($appearance.item_background_height)"
    background.y_offset=0
    $"background.color=($appearance.item_background_colour)"
    $"background.corner_radius=($appearance.item_background_corner_radius)"
    blur_radius=30
    background.padding_right=4
    $"background.border_width=1"
    $"background.border_color=($colour.glass_dark)"
    # background.shadow.distance=1
    # $"background.shadow.color=($colour.grey)"

    ###--------------------
    ##   Icon
    #----------------------
    icon.padding_left=10
    icon.padding_right=10
    # Ensure icon is drawn as empty space, which would then be replaced with
    # the icon image of the app.
    icon.background.drawing=on
    icon.background.image.scale=0.8
    icon.background.image.padding_left=0
    icon.background.image.padding_right=5


    ###--------------------
    ##   Label
    #----------------------
    # $"label.color=($appearance.item_label_colour)"
    $"label.font=($appearance.item_font):Light:13.0"
    label.padding_right=10
    label.y_offset=-1

    ###--------------------
    ##   Misc Appearance
    #----------------------
    padding_left=4

    ###--------------------
    ##   Logic
    #----------------------
    script="nu ./front_app.nu"
    --subscribe $"($name)" front_app_switched
  )

  log info $"Rendering ($name), complete"
}

# main runs based on event subscription, and update the front_app item so that
# the current application is correctly rendered in the item. It also fetches the
# application icon.
def main () {
  log debug "Called based on subscription"

  # This shouldn't happen, but ensuring subscription doesn't handle incorrect
  # event.
  if $env.SENDER != front_app_switched {
    log debug $"Other event caught: ($env.SENDER)"
    return ()
  }

  log debug $"Subscription based on \"front_app_switched\" for ($env.INFO)"
  (sketchybar
    --set $name
    $"label=($env.INFO)"
    $"icon.background.image=app.($env.INFO)"
  )

  () # Return nothing
}
