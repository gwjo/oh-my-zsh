# {{{ Split matches into groups
zstyle ':completion:*:matches' group 'yes'

# }}}
# {{{ Group descriptions/message/warning formats
zstyle ':completion:*:descriptions' format "%B---- %d%b"
zstyle ':completion:*:messages' format '%B%U---- %d%u%b' 
zstyle ':completion:*:warnings' format '%B%U---- no match for: %d%u%b'

# }}}
# {{{ Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# }}}
# {{{ Don't complete backup files (e.g. 'bin/foo~') as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# }}}

