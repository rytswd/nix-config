# This file contains options that need to be enabled early in the plugin setup.

# Set word selection style to be in line with Bash.
# This allows selecting only up to the next symbol character.
# This must be called before zsh-history-substring-search.
autoload -U select-word-style
select-word-style bash
