#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "network"

export def item () {
  log info $"Rendering ($name)"

  # sketchybar command requires the specific syntax to be followed. For some
  # complex scenarios, I need to set up a separate variable and pass that into
  # the command.

  (sketchybar
    --add item $"($name)_up" right
    --set      $"($name)_up"
    width=0
    "icon="
    $"icon.color=($colour.red)"
    $"icon.width=20"
    $"icon.font.size=10.5"
    $"icon.y_offset=1"
    $"icon.padding_left=0"
    $"icon.align=left"

    "label=??? bps"
    # $"label.color=($colour.red)"
    $"label.font=($appearance.item_font):Thin:8.5"
    $"label.padding_left=0"
    $"label.align=right"
    $"label.width=32"

    # Offset to show at top half
    y_offset=4
    )
  (sketchybar
    --add item $"($name)_down" right
    --set      $"($name)_down"
    width=0
    "icon="
    $"icon.color=($colour.blue)"
    $"icon.width=20"
    $"icon.font.size=10.5"
    $"icon.y_offset=1"
    $"icon.padding_left=0"
    $"icon.align=left"

    "label=??? bps"
    # $"label.color=($colour.blue)"
    $"label.font=($appearance.item_font):Thin:8.5"
    $"label.padding_left=0"
    $"label.align=right"
    $"label.width=32"

    # Offset to show at bottom half
    y_offset=-4
    )
  (sketchybar
    --add item $name right
    --set      $name
    position=right

    $"background.height=($appearance.item_background_height)"
    $"background.y_offset=0"
    $"background.color=($appearance.item_background_colour)"
    $"background.padding_right=4"
    $"background.padding_left=4"
    $"background.corner_radius=($appearance.item_background_corner_radius)"
    $"background.border_width=1"
    $"background.border_color=($colour.glass_dark)"

    # This is an icon only item and shifting so that the other network details
    # can be seen in the remaining space.
    "icon=󱛇"
    $"icon.color=($colour.muted)"
    $"icon.width=20"
    $"icon.font.size=20"
    $"icon.y_offset=1"
    icon.padding_left=-52
    width=72

    label.drawing=false

    script="nu ./network.nu"
    --subscribe $name network_update wifi_change system_woke
  )

  # Because the network details are best shown together, using a dedicated
  # bracket to group the items above.
  (sketchybar
    --add bracket right
      $name
      $"($name)_up"
      $"($name)_down"
    --set         right
    # $"blur_radius=($appearance.item_blur_radius)"
    # $"background.border_color=($colour.green)"
    # $"background.border_width=2"
    # $"padding_right=($appearance.bracket_padding_side)"
    # $"background.padding_left=20"
  )

  log info $"Rendering ($name), complete"
}

def main () {
  log debug "Called based on subscription"

  if $env.SENDER == network_update {
    network_load
    return ()
  }

  if ($env.SENDER == wifi_change or $env.SENDER == system_woke) {
    wifi_change
    return ()
  }

  log debug $"Other event caught: ($env.SENDER)"
}

def network_load () {
  let up_colour = if ($env.upload != "000 Bps") {$colour.red} else {$colour.grey}
  let down_colour = if ($env.download != "000 Bps") {$colour.blue} else {$colour.grey}

  (sketchybar
    --set $"($name)_up"
    $"label=($env.upload)"
    $"icon.color=($up_colour)"
  )
  (sketchybar
    --set $"($name)_down"
    $"label=($env.download)"
    $"icon.color=($down_colour)"
  )
}

def wifi_change () {
  let wifi_icon = if (ipconfig getifaddr en0 | is-not-empty) {"󰖩"} else {"󰖪"}
  let wifi_icon_colour = if (ipconfig getifaddr en0 | is-not-empty) {$appearance.item_icon_colour} else {$colour.muted}

  (sketchybar
    --set $name
    $"icon=($wifi_icon)"
    $"icon.color=($wifi_icon_colour)"
  )
}
