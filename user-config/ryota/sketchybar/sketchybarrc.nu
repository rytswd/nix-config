#!/usr/bin/env nu

###========================================
##   Sketchybar With NuShell
#==========================================
#
# Because sketchybar configuration is simply some shell commands, I'm making
# use of NuShell for making it easier to read.
#

use std log

# Import colours, and other common settings
use colour.nu
use appearance.nu

def main [] {
  log info "Sketchybarrc being loaded, initialising..."

  ###----------------------------------------
  ##   Default Settings
  #------------------------------------------
  log info "Setting up default values"
  (sketchybar --default
    ###--------------------
    ##   Background
    #----------------------
    # Ensure height of the background fills the height of the bar by default.
    $"background.height=($appearance.bar_height)"

    ###--------------------
    ##   Icon
    #----------------------
    # Icon setup
    $"icon.font=($appearance.font):Bold:17.0"
    $"icon.color=($colour.white)"

    ###--------------------
    ##   Label
    #----------------------
    # Label setup
    $"label.font=($appearance.font):Bold:14.0"
    $"label.color=($colour.white)"

    ###--------------------
    ##   Padding
    #----------------------
    # Ref: https://felixkratz.github.io/SketchyBar/config/items
    padding_left=0
    padding_right=0
    # There is no padding set between icon and label.
    icon.padding_left=10
    icon.padding_right=0
    label.padding_left=0
    label.padding_right=10
  )
  log info "Setting up default values, complete"


  ###----------------------------------------
  ##   Bar Appearance
  #------------------------------------------
  # Bar goes from left to right all the way on top or bottom of the screen.
  log info "Setting up the bar"
  (sketchybar --bar
    position=top
    sticky=on
    display=all

    $"height=($appearance.bar_height)"
    $"y_offset=($appearance.top_margin)"
    $"margin=($appearance.yabai_padding)"

    # Remove any padding in case bar is not visible. When padding is really
    # needed, it can be set to items instead.
    padding_right=0
    padding_left=0

    corner_radius=10

    notch_width=200

    $"color=($colour.transparent)"
    # $"shadow=($colour.grey)"
    blur_radius=10
  )
  log info "Setting up the bar, complete"


  ###--------------------
  ##   Items
  #----------------------
  # Item is the actual component shown. Each has different configuration for
  # look and feel, including some logic for updates.
  log info "Setting up the items"

  # Left -- the first item will be leftmost
  use apple.nu; apple icon
  # use space.nu; space item # TODO: This is not working correctly.
  use front_app.nu; front_app item

  # Right -- the first item will be rightmost
  use datetime.nu; datetime clock item; datetime calendar item
  use battery.nu; battery item
  use input.nu; input item

  log info "Setting up the items, complete"

  ###--------------------
  ##   Brackets
  #----------------------
  # Brakcet is a group mechanism to give some style.
  #
  # The item names assume that, unless in some special condition such as
  # aliases, they match the name of the item created above (i.e. the file name).
  log info "Setting up brackets"

  (sketchybar
    --add bracket left
      # List of items to belong to the bracket
      # '/space\..*/' # TODO: Commenting out while this is being worked on.
      front_app
    --set         left
    $"background.color=($appearance.bracket_background_colour)"
    $"background.height=($appearance.bracket_height)"
    $"background.corner_radius=($appearance.bracket_background_corner_radius)"
    # $"background.border_color=($colour.orange)"
    # $"background.border_width=1"
    # $"padding_left=($appearance.bracket_padding_side)"
  )

  (sketchybar
    --add bracket right
      # List of items to belong to the bracket
      clock
      calendar
      battery
      "TextInputMenuAgent,Item-0"
    --set         right
    $"background.color=($appearance.bracket_background_colour)"
    $"background.height=($appearance.bracket_height)"
    $"background.corner_radius=($appearance.bracket_background_corner_radius)"
    # $"background.border_color=($colour.green)"
    # $"background.border_width=1"
    # $"padding_right=($appearance.bracket_padding_side)"
  )

  log info "Setting up brackets, complete"

  ###--------------------
  ##   Initialise
  #----------------------
  # Update whenever change is made -- good for development use cases.
  sketchybar --hotload on
  # Force all item scripts to run
  sketchybar --update

  log info "Sketchybarrc configured"
}
