# Alt-m - copy the directly previous word.
# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
bindkey "^[m" copy-prev-shell-word

# Search with Ctrl+r and Ctrl+s.
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# Ensure Ctrl+u is set to kill-line backward
bindkey '^U' backward-kill-line
