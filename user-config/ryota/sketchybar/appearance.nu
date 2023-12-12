#!/usr/bin/env nu

use colour.nu

###========================================
##   Appearance
#==========================================

# Default font - Nerd Font may not be necessary, but setting it just in case.
export const font = "Hack Nerd Font"

###========================================
##   Bar Related
#==========================================
# Bar is the main component which runs across the entire screen width.

###----------------------------------------
##   macOS Related
#------------------------------------------
export const notch_height = 32 # For reference

###----------------------------------------
##   yabai Related
#------------------------------------------
export const yabai_padding = 12

###----------------------------------------
##   Bar Settings
#------------------------------------------
export const top_padding   = 2
export const top_margin    = 2
export const bar_height    = 36


###========================================
##   Bracket Related
#==========================================
# Bracket is a small bar like component to group items.
export const bracket_height                     = 22
# export const bracket_background_colour          = $colour.glass
export const bracket_background_colour          = $colour.transparent
export const bracket_background_corner_radius   = 7
export const bracket_padding_side               = 4

###========================================
##   Item Related
#==========================================
# All the item related definitions from here.

###----------------------------------------
##   Item Background Related
#------------------------------------------
# Background height based is meant to be slightly smaller than the bar itself.
export const item_background_height         = 16
export const item_background_corner_radius  = 2

# Background blur radius
export const item_blur_radius               = 30
export const item_font                      = "FiraMono Nerd Font"
