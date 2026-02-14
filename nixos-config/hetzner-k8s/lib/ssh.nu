# SSH helpers for ephemeral Hetzner servers.
#
# All servers are short-lived and may be recreated with different host keys,
# so we unconditionally accept new keys and suppress warnings.

export const OPTS = [
  "-o" "StrictHostKeyChecking=no"
  "-o" "UserKnownHostsFile=/dev/null"
  "-o" "ConnectTimeout=10"
  "-o" "LogLevel=ERROR"
]

# Run a command on a remote host as root.
export def run [ip: string, cmd: string] {
  ssh ...$OPTS $"root@($ip)" $cmd
}

# Wait until sshd is reachable (up to ~150 s).
export def wait [ip: string] {
  print $"  Waiting for SSH on ($ip) ..."
  mut attempts = 30
  loop {
    if $attempts <= 0 {
      error make { msg: $"SSH not reachable on ($ip) after 150 s" }
    }
    try {
      ssh ...$OPTS $"root@($ip)" true
      return
    }
    sleep 5sec
    $attempts -= 1
  }
}
