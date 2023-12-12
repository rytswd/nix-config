#/usr/bin/env nu

use std log

use appearance.nu
use colour.nu

# This is rather a temporary solution for now.

export def items [] {
  log info "Rendering stats alias based widgets"

  let widgets = [
    "Stats,Network"
    "Stats,RAM"
    "Stats,CPU"
  ]

  ($widgets | enumerate | each {|it| (sketchybar
    --add alias $it.item right
    --set       $it.item
    ###--------------------
    ##   Background
    #----------------------
    # $"background.color=($appearance.bracket_background_colour)"
    # $"background.corner_radius=($appearance.item_background_corner_radius)"
    # $"background.height=($appearance.item_background_height)"
    # $"blur_radius=($appearance.item_blur_radius)"
    $"background.padding_left=0"
    $"background.padding_right=(if $it.index == 0 {-10} else {-10})"

    ###--------------------
    ##   Icon
    #----------------------
    $"icon.drawing=off"

    ###--------------------
    ##   Label
    #----------------------
    $"label.drawing=off"

    ###--------------------
    ##   Misc Appearance
    #----------------------
    # N/A

    ###--------------------
    ##   Logic
    #----------------------
    # click_script=$"($env.__POPUP_CLICK_SCRIPT)"
    # popup.height=35
  )})

  ($widgets |
    (sketchybar
      --add bracket stats_widgets $in
      --set         stats_widgets
      $"background.color=($appearance.bracket_background_colour)"
      # $"background.color=($colour.glass_dark)"
      $"background.height=($appearance.bracket_height)"
      $"background.corner_radius=($appearance.bracket_background_corner_radius)"
      # $"background.border_color=($colour.orange)"
      # $"background.border_width=2"
      $"background.padding_left=20"
      $"background.padding_right=20"
      $"icon.padding_left=20"
      $"icon.padding_right=20"
      $"label.padding_left=20"
      $"label.padding_right=20"
    )
  )

  log info "Rendering stats alias based widgets, complete"
}
