#!/usr/bin/env nu

let current_background = (
  swww query
    | str replace -r '.+currently displaying: image: (.+)' '$1')

let pictures = (
  ls ~/Pictures/Wallpapers/
    | where type == file
    | where name != $current_background)

let num_of_pics = (($pictures | length) - 1) # Adjusting for idx use
let new_idx = (random int 0..$num_of_pics)

let new_picture = (
  $pictures
    | get $new_idx
    | get name
    | swww img $in --transition-type random)
