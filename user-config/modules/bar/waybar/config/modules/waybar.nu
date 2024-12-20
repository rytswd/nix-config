#!/usr/bin/env nu

use std

# Signal to update the Waybar icons.
let signal = 9

def main (input?: string) {
  match $input {
    "status_left" => (get_status waybar_left | match $in {
        true => '{"text": "", "class": "running"}'
        false => '{"text": ""}'
    })
    "toggle_left" => (toggle waybar_left)
    "status_bottom" => (get_status waybar_bottom | match $in {
        true => '{"text": "", "class": "running"}'
        false => '{"text": ""}'
    })
    "toggle_bottom" => (toggle waybar_bottom)
    _ => ()
  }
}

def get_status (service_name) {
  do -i { systemctl --user is-active $service_name }
    | complete
    | match $in.exit_code {
        0 => {
          std log info $"'($service_name)' is running"
          true
        }
        3 => {
          std log info $"'($service_name)' not running"
          false
        }
        4 => {
          std log error $"service with name '($service_name)' not found"
          false
        }
        _ =>  {
          std log error $"unknown error with service with name '($service_name)', ($in.stderr)"
          false
        }
    }
}

def toggle (service_name) {
  std log info $"toggle for the service '($service_name)' triggered"
  (get_status $service_name | match $in {
    true => (do -i { systemctl --user stop $service_name} | complete)
    false => (do -i { systemctl --user start $service_name} | complete)
  } | match $in.exit_code {
    0 => (std log info "toggle complete")
    _ => (std log error $"toggle failed: ($in.stderr)")
  })

  # This assumes that the module is called from Waybar.
  # Waybar module can update its look by getting signal.
  let parent_pid = (ps | where pid == $nu.pid | get ppid | first)
  do -i {coreutils --coreutils-prog=kill --signal=$"RTMIN+($signal)" $parent_pid}
}
