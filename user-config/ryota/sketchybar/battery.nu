#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "battery"

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
    # Icon will be rendered based on battery percentage
    # $"icon.color=($appearance.item_icon_colour)"
    $"icon.width=10"
    $"icon.font.size=23"
    $"icon.y_offset=1"
    $"icon.padding_left=0"


    ###--------------------
    ##   Label
    #----------------------
    # $"label.color=($appearance.item_label_colour)"
    $"label.font=($appearance.item_font):Thin:13.0"
    $"label.align=right"
    $"label.padding_left=7"
    $"label.padding_right=5"
    $"label.y_offset=-1"

    ###--------------------
    ##   Misc Appearance
    #----------------------

    ###--------------------
    ##   Logic
    #----------------------
    update_freq=120
    script="nu ./battery.nu"
    --subscribe $"($name)" power_source_change system_woke
  )

  log info $"Rendering ($name), complete"
}

# main runs based on event subscription, and update the front_app item so that
# the current application is correctly rendered in the item. It also fetches the
# application icon.
def main () {
  let b = (pmset -g batt)
  let percentage = ($b | parse --regex '(?P<Pct>\d+)%' | get 0 | get Pct | into int)
  let ac_on = ($b | str contains 'AC Power')

  mut icon = "󱟩"
  mut battery_colour = $"($appearance.item_label_colour)"
  let battery_label = $"($percentage | fill -a right -c ' ' -w 2)%"

  if ($ac_on) {
    $icon = ($percentage | map-to-icon-with-power)
  } else {
    $icon = ($percentage | map-to-icon)
  }

  if ($percentage > 5 and $percentage <= 20) {
    $battery_colour = $"($colour.orange)"
  } else if ($percentage <= 5) {
    $battery_colour = $"($colour.red)"
  }

  mut padding_adjustment = $"label.padding_left=7"
  if ($ac_on) { $padding_adjustment = $"label.padding_left=12" }

  (sketchybar
    --set ($name)
    $"icon=($icon)"
    $"icon.color=($battery_colour)"
    $"label=($battery_label)"
    $"($padding_adjustment)"
  )
}

def map-to-icon () {
  # Assumes the battery percentage is provided as pipe input
  let battery = $in | into int
  mut index = 0

  if ($battery > 70) {
    $index = 3
  } else if ($battery > 30) {
    $index = 2
  } else if ($battery > 10) {
    $index = 1
  } else {
    $index = 0
  }

  [󱉞 󱊡 󱊢 󱊣] | get $index
}

def map-to-icon-with-power () {
  # Assumes the battery percentage is provided as pipe input
  let battery = $in | into int
  mut index = 0

  if ($battery > 70) {
    $index = 3
  } else if ($battery > 30) {
    $index = 2
  } else if ($battery > 10) {
    $index = 1
  } else {
    $index = 0
  }

  [󰢟 󱊤 󱊥 󱊦] | get $index
}
