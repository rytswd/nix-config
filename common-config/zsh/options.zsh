# List of Zsh options
# Ref: http://manpages.ubuntu.com/manpages/bionic/man1/zshoptions.1.html

# ====================
#   Completion
# ====================

# When completion is started, the cursor stays where it is for both end
# completion.
setopt COMPLETE_IN_WORD

# When completion match is found and inserted, move the cursor to the end.
setopt ALWAYS_TO_END

# ====================
#   Directory
# ====================

# cd into the directory without explicit 'cd'.
setopt AUTO_CD

# Track dir change with cd just like pushd, and ignore dupes.
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Have pushd with no arguments act like `pushd $HOME'.
setopt PUSHD_TO_HOME

# ====================
#   Globbing
# ====================

# Add trailing slash for matched directories.
setopt MARK_DIRS

# ====================
#   History
# ====================

# Append history from multiple zsh instances. This also appends as early as
# when the command is entered, raher than waiting for it to exit.
setopt INC_APPEND_HISTORY

# Skip history addition when command starts with a preceding space.
setopt HIST_IGNORE_SPACE

# Don't execute the history directly.
setopt HIST_VERIFY

# ====================
#   Input
# ====================

# Prompt for spelling correction of commands.
setopt CORRECT

# Use Dvorak for spelling correction.
setopt DVORAK

# Allow comments in interactive shell.
setopt INTERACTIVE_COMMENTS

# Disable flow control. This is important for Ctrl-s autocomplete forward
# lookup to function with Ctrl-s.
setopt NO_FLOW_CONTROL



# ====================
#   Extra
# ====================

# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '

# // 💫 zsh-syntax-highlighting
# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
