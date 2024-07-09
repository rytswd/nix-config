#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# In order to simplify "bracket" handling, it is best to stick the file name for
# the name variable here. That way, it can be referred to with the same name
# throughout.
export const name = "cpu"

export def item () {
  log info $"Rendering ($name)"

  # sketchybar command requires the specific syntax to be followed. For some
  # complex scenarios, I need to set up a separate variable and pass that into
  # the command.

  (sketchybar
    --add graph $name right 36
    --set       $name
    ###--------------------
    ##   Background
    #----------------------
    $"background.height=($appearance.item_background_height)"
    $"background.y_offset=0"

    $"background.color=($appearance.item_background_colour)"
    $"background.padding_right=4"
    $"background.padding_left=4"
    $"background.corner_radius=($appearance.item_background_corner_radius)"
    $"background.border_width=1"
    $"background.border_color=($colour.glass_dark)"
    $"blur_radius=($appearance.item_blur_radius)"

    ###--------------------
    ##   Icon
    #----------------------
    $"icon="
    $"icon.color=($appearance.item_icon_colour)"
    $"icon.width=20"
    $"icon.font.size=20"
    $"icon.y_offset=1"
    $"icon.padding_left=0"

    ###--------------------
    ##   Graph
    #----------------------
    $"graph.color=($appearance.item_main_colour)"
    graph.line_width=0.8

    ###--------------------
    ##   Label
    #----------------------
    $"label.string=cpu ??%"
    $"label.font=($appearance.item_font):Thin:8.5"
    $"label.align=left"
    $"label.padding_left=-32"
    $"label.padding_right=0"
    $"label.y_offset=4"
    $"label.width=10"

    ###--------------------
    ##   Misc Appearance
    #----------------------
    # N/A

    ###--------------------
    ##   Logic
    #----------------------
    script="nu ./cpu.nu"
    click_script="open '/System/Applications/Utilities/Activity Monitor.app'"
    --subscribe $"($name)" cpu_update
  )

  log info "Rendering cpu, complete"
}

def main () {
  log debug "Called based on subscription"

  # When called by other event, ignore.
  if $env.SENDER != cpu_update {
    log debug $"Other event caught: ($env.SENDER)"
    return ()
  }

  # NOTE: Based on the current C based impl, the load can be one of the following:
  # - total_load
  # - user_load
  # - sys_load
  let load = ($env.total_load | into int)
  let load_percent = $load / 100

  (sketchybar
    --push $name $load_percent)

  mut graph_colour = $appearance.item_main_colour
  if ($load > 80) {
    $graph_colour = $colour.red
  } else if ($load > 60) {
    $graph_colour = $colour.orange
  } else if ($load > 30) {
    $graph_colour = $colour.yellow
  } else if ($load > 20) {
    $graph_colour = $colour.blue
  } else {
    $graph_colour = $appearance.item_main_colour
  }

  (sketchybar
    --set $name
    $"graph.color=($graph_colour)"
    $"label=cpu ($load)%"
  )
}
