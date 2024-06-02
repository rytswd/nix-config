#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

export module calendar {
  export const name = "calendar"

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
      $"background.height=($appearance.item_background_height)"
      $"background.y_offset=0"
      $"background.color=($appearance.item_background_colour)"
      $"background.padding_right=4"
      $"background.padding_left=0"
      $"background.corner_radius=($appearance.item_background_corner_radius)"
      $"blur_radius=($appearance.item_blur_radius)"

      ###--------------------
      ##   Icon
      #----------------------
      # N/A
      $"icon="
      $"icon.color=($appearance.item_icon_colour)"
      # $"icon.color=($colour.blue)"
      # $"icon.background.color=($colour.blue)"

      $"icon.width=18"
      $"icon.font.size=24"
      $"icon.background.height=17"
      $"icon.y_offset=2"
      $"icon.background.y_offset=0"
      $"icon.background.corner_radius=0"
      $"icon.padding_left=3"


      ###--------------------
      ##   Label
      #----------------------
      $"label.color=($appearance.item_label_colour)"
      $"label.font=($appearance.item_font):Light:13.0"
      # $"label.width=85"
      $"label.align=right"
      $"label.padding_left=9"
      $"label.padding_right=5"
      $"label.y_offset=-1"

      ###--------------------
      ##   Misc Appearance
      #----------------------

      ###--------------------
      ##   Logic
      #----------------------
      # This "calendar" relies on the below "clock" to handle the updates.
      # update_freq=1
      # script="nu ./datetime.nu"
    )

    log info $"Rendering ($name), complete"
  }
}

export module clock {
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
      $"background.height=($appearance.item_background_height)"
      $"background.y_offset=0"

      $"background.color=($appearance.item_background_colour)"
      $"background.padding_right=4"
      $"background.padding_left=0"
      $"background.corner_radius=($appearance.item_background_corner_radius)"
      $"blur_radius=($appearance.item_blur_radius)"

      ###--------------------
      ##   Icon
      #----------------------
      # Icon will be rendered based on time
      $"icon.color=($appearance.item_icon_colour)"
      # $"icon.color=($colour.green)"
      # $"icon.background.color=($colour.green)"

      $"icon.width=18"
      $"icon.font.size=27"
      $"icon.background.height=17"
      $"icon.y_offset=1"
      $"icon.background.y_offset=1"
      $"icon.background.corner_radius=25"
      $"icon.padding_left=3"


      ###--------------------
      ##   Label
      #----------------------
      $"label.color=($appearance.item_label_colour)"
      $"label.font=($appearance.item_font):Thin:13.0"
      $"label.width=65"
      $"label.padding_left=9"
      $"label.y_offset=-1"

      ###--------------------
      ##   Misc Appearance
      #----------------------

      ###--------------------
      ##   Logic
      #----------------------
      update_freq=1
      script="nu ./datetime.nu"
    )

    log info $"Rendering ($name), complete"
  }
}

# main returns the current time in a given format.
def main () {
  let d = (date now)
  let now = ($d | format date "%H:%M:%S")
  let today = ($d | format date "%a, %-d %b")
  let now_icon = ($d | format date "%-I" | map-to-icon)
  sketchybar --set clock    $"label=($now)" $"icon=($now_icon)"
  sketchybar --set calendar $"label=($today)"
}

def map-to-icon () {
  let index = $in | into int
  [            ] | get $index
}
