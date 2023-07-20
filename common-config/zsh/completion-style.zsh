# Completion like oh-my-zsh
# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/completion.zsh
# Ref: https://thevaluable.dev/zsh-completion-guide-examples/

# Use completeion menu selection
zstyle ':completion:*:*:*:*:*' menu select

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Set case insensitive, search anywhere
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Coloring
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# Add separator such as '-- local directory --'
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'

# Correctly map with group
zstyle ':completion:*' group-name ''

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# Use fuzzy matching
zstyle ':completion:*' fuzzy true

# Expand aliases
zstyle ':completion:*' completer _expand_alias _complete _ignored

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
    adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
    clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
    gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
    ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
    operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
    usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Ref: https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh
# [Shift-Tab] - move through the completion menu backwards
if [[ -n "${terminfo[kcbt]}" ]]; then
    bindkey -M emacs "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
    bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete
fi
