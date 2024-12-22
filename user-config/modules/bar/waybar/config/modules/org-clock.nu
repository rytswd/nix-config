#!/usr/bin/env nu

# Signal to update the Waybar icons.
let signal = 7

def main (input?: string) {
  match $input {
    "status" => (get_status)
    "toggle" => (toggle)
    _ => ()
  }
}

def get_status () {
  let status_string = (do -i
    { (emacsclient --eval
        "(when (featurep 'org)
          (when (org-clocking-p)
            (substring-no-properties (org-clock-get-clock-string))))") })
    | complete
    | match $in {
        {exit_code: 0, stdout: $str} => ($str | str trim)
        {exit_code: 1} => ()
        _ => ()
    }

  if $status_string == "nil" {
    return '{"text": "No active task.", "class": "none"}'
  }

  let status = (do -i
    { (emacsclient --eval 'org-clock-task-overrun') }
    | complete
    | match ($in.stdout | str trim) {
        "t" => "overrun"
        "nil" => "running"
        _ => "unknown" # Catching other cases just to be safe.
    })

  $status_string
    | parse -r '"(?P<time>\[.+\]) \((?P<title>.+)\) "'
    | first # There is no way to have multiple items, but ensure to flatten
    | $'{"text": "($in.time) -> ($in.title)", "class": "($status)"}'
}

def toggle () {
  (do -i {
    (emacsclient --eval
        '(if (org-clocking-p) (org-clock-out) (org-clock-in-last))')})
    | complete

  # This assumes that the module is called from Waybar.
  # Waybar module can update its look by getting signal.
  let parent_pid = (ps | where pid == $nu.pid | get ppid | first)
  do -i {coreutils --coreutils-prog=kill --signal=$"RTMIN+($signal)" $parent_pid}
}
