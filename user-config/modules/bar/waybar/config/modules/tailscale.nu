#!/usr/bin/env nu

# Signal to update the Waybar icons.
let signal = 10
# Use --login-server if the login server is set in the env variable. If not set,
# this will be an empty string.
let login_server_flag = (
  $env | try { get TAILSCALE_LOGIN_SERVER | $'--login-server=($in)' } catch { "" })

def main (input?: string) {
  match $input {
    "status" => (write_status | print -n -r $in)
    "toggle" => (toggle_tailscale)
    _ => ()
  }
}

# TODO: Handle error case with tailscale early, and use complete and match.
# TODO: Handle without sudo -- for some reason when triggered from the script,
# I need sudo in place.

def get_status () {
  (do -i { tailscale status --json }
        | from json
        | get BackendState)
}

def write_status () {
  (get_status
    | match $in {
        "Running" => '{"text": "󰢩"}'
        # In case of connection issue, add an extra class for styling.
        "Stopped" => '{"text": "󰱟", "class": "disconnected"}'
        "NoState" => '{"text": "󰱟", "class": "disconnected"}'
        _ => '{"text": "", "class": "unknown"}' # Unknown state
    })
}

def toggle_tailscale () {
  (get_status
    | match $in {
        "Running" => (
          do -i { tailscale down })
        "Stopped" => (
          do -i {
            if ($login_server_flag == "") {
              # NOTE: Without the env variable setup, there will be no
              # login server specified.
              tailscale up
            } else {
              (tailscale up
                  $login_server_flag
                  --accept-routes
                  --ssh
                  --operator=$env.USER)}
          })
        # In case of unknown state, assume it's not connected, and retry.
        _ => (
          do -i {
            if ($login_server_flag == "") {
              # NOTE: Without the env variable setup, there will be no
              # login server specified.
              tailscale up
            } else {
              (tailscale up
                  $login_server_flag
                  --accept-routes
                  --ssh
                  --operator=$env.USER)}
          })
    })

  # This assumes that the module is called from Waybar.
  # Waybar module can update its look by getting signal.
  let parent_pid = (ps | where pid == $nu.pid | get ppid | first | default 0)
  if ($parent_pid == 0) {
    do -i { coreutils --coreutils-prog=kill --signal=$"RTMIN+($signal)" $parent_pid }
  }
}
