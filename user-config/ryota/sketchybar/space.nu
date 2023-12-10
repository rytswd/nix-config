#/usr/bin/env nu

use std log

use colour.nu
use appearance.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "space"

# item renders the special component called "space". Any extra logic such as
# updates and event subscription are handled in separate functions.
# Note that, because the file name is "space.nu", this cannot export a function
# named "space", and thus simply using the same name as other components.
export def item () {
  log info $"Rendering ($name)"

  for $i in 1..5 {
    log info $"Handling ($name).($i)..."

    (sketchybar
      --add space $"($name).($i)" left
      --set       $"($name).($i)"
      $"space=$i"
      $"associated_space=$i"
      ###--------------------
      ##   Background
      #----------------------
      $"background.height=($appearance.background_height)"
      background.y_offset=0
      $"background.color=($colour.blue)"
      $"background.corner_radius=($appearance.background_corner_radius)"
      # blur_radius=3
      $"background.border_color=($colour.black)"
      $"background.border_width=2"
      # background.padding_right=4
      # background.shadow.distance=1
      # $"background.shadow.color=($colour.grey)"

      ###--------------------
      ##   Icon
      #----------------------
      icon="󰊠"
      # icon.padding_left=10
      # icon.padding_right=10
      # Ensure icon is drawn as empty space, which would then be replaced with
      # the icon image of the app.
      # icon.background.drawing=on
      # icon.background.image.scale=0.5
      # icon.background.image.padding_left=5
      # icon.background.image.padding_right=5

      ###--------------------
      ##   Label
      #----------------------
      $"label.color=($colour.black)"
      # label.font="FiraMono Nerd Font:Light:13.0"
      # label.padding_right=10
      # label.y_offset=-1
      $"label=__"

      ###--------------------
      ##   Misc Appearance
      #----------------------
      # padding_left=4

      ###--------------------
      ##   Logic
      #----------------------
      script="nu ./space.nu"
      --subscribe $"($name).($i)" front_app_switched space_change space_windows_change
    )
  }
  log info $"Handling ($name) items, complete"

  log info $"Rendering ($name), complete"
}

# main is the logic used for handling the space information, and supply it back
# to the sketchybar item.
def main () {
  log info $"($name): ($env.NAME) - \"($env.SENDER)\" event triggered; selected: ($env.SELECTED), sid: ($env.SID), did: ($env.DID)"

  # This shouldn't happen, but ensuring subscription doesn't handle incorrect
  # event.
  if ($env.SENDER | find "space_change" "forced" | is-empty) {
    log debug $"Other event caught: ($env.SENDER)"
    return ()
  }

  if $env.SENDER == forced {
    log info $"Subscription based on \"forced\", ($env.NAME), ($env.SELECTED)"
    (sketchybar
      # --animate sin 10
      --set $"($env.NAME)"
      # display=active
      $"label=($env.SID)"
      $"icon.highlight=($env.SELECTED)"
      # $"icon.background.image=app.($env.INFO)"
    )
    return ()
  }

  # A bit convoluted, but this checks whether the event is from the list of
  # events. Could not find any better way to write this...
  if ($env.SENDER | find -v "space_change" "space_windows_change" | is-empty ) {
    log info $"Subscription based on \"space_windows_change\" for ($env.INFO)"
    let space = ($env.INFO | from json | get 'space')
    let apps = ($env.INFO | from json | get 'keys[]')
    let app_count = ($env.INFO | jq -r '.apps | length')
    (sketchybar
      -m
      --animate sin 10
      --set $"($env.NAME)"
      $"label=xxx ($app_count)"
      $"label.highlight=($env.SELECTED)"
      # $"icon.background.image=app.($env.INFO)"
    )
    return ()
  }

  () # Return nothing
}
