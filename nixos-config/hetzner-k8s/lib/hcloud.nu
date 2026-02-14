# Hetzner Cloud CLI helpers.

# Collect all SSH key names registered in the project.
# Returns a flat list: ["--ssh-key" "key1" "--ssh-key" "key2" ...]
export def ssh-key-args [] {
  (hcloud ssh-key list -o columns=name -o noheader
    | lines
    | each { |k| $k | str trim }
    | where { |k| ($k | is-not-empty) }
    | each { |k| ["--ssh-key" $k] }
    | flatten)
}

# Get the IPv4 address for a server (empty string if not found).
export def get-ip [name: string] {
  try { hcloud server ip $name | str trim } catch { "" }
}
