#!/usr/bin/env nu

use std

# This script assumes the following items to be available:
#   wf-recorder: https://github.com/ammen99/wf-recorder
#   pueue: https://github.com/Nukesor/pueue

# Signal to update the Waybar icons.
let signal = 11
mut pid = null

def main (input?: string) {
  set_up_pueue

  match $input {
    "status" => (write_status | print -n -r $in)
    "toggle" => (toggle_recording)
    _ => ()
  }
}

def set_up_pueue () {
  # This uses pueue behind the scenes.
  if (which pueue | is-empty) {
    std log error "'pueue' command not found."
    return 1
  }
  if (do { pueue status -j } | complete | get exit_code | $in != 0 ) {
    std log error "'pueued' not running."
    return 1
  }

  # Ensure pueue has a dedicated "waybar" group.
  if not (pueue status -j | from json | get groups | "wf-recorder" in $in) {
    pueue group add --parallel 0 wf-recorder
  }
}

def get_status () {
  let status = (do -i { pueue status -j } | complete)

  if $status.exit_code != 0 { "unknown" } else {
    ($status.stdout
      | from json
      | get tasks
      | transpose         # Rows and columns are swapped for some reason
      | get column1       # Ignore column0 which has no info
      | get status        # For some reason I need explicit column retrieval first
      | "Running" in $in
      | match $in {
          true => "running"
          false => "stopped"
      })
  }
}

def write_status () {
  (get_status
    | match $in {
        "running" => '{"text": "󰑋", "class": "running"}'
        "stopped" => '{"text": "󰻃", "class": "stopped"}'
        _         => '{"text": "󱔢", "class": "unknown"}'
    })
}

def toggle_recording () {
  (get_status
    | match $in {
        "stopped" => (start_recording)
        "running" => (stop_recording)
        _         => () # When in unknown state, pueue is likely not working, and thus not scheduling work.
    })

  # This assumes that the module is called from Waybar.
  # Waybar module can update its look by getting signal.
  let parent_pid = (ps | where pid == $nu.pid | get ppid | first)
  do -i {coreutils --coreutils-prog=kill --signal=$"RTMIN+($signal)" $parent_pid}
}

def stop_recording () {
  # It's a bit extreme, but I shouldn't be reusing the same pueue group for
  # various purposes, and thus I do the entire group clean up when a process
  # is found to be running.
  (do -i { pueue kill -g wf-recorder })
}

def start_recording () {
  let timestamp = (date now | format date "%Y%m%d-%H%M%S")
  let filename = $"($env.HOME)/Videos/Screencasts/($timestamp).webm"

  let pid = (do -i { slurp }
    | complete
    | match $in.exit_code {
        0 => ($in.stdout)
        _ => (return 1) # Early return from the function
    }
    | pueue add -g wf-recorder -i -p # i for immediate, p for process ID
            wf-recorder --codec libvpx --geometry $"'($in)'" --file ($filename) )
}
