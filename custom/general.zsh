## {{{ unalias which
##
## reverse unwanted aliasing of `which' by distribution startup
## files (e.g. /etc/profile.d/which*.sh); zsh's 'which' is perfectly
## good as is.

alias which >&/dev/null && unalias which

## }}}
## {{{ Shell parameters

## Report who logs into my machines
LOGCHECK=60
WATCHFMT="[%B%T %w%b] %B%n%b has %a %B%l%b from %B%M%b"
WATCH=notme

## Let me if a command runs longer than a minute.  Useful
## for timing builds
REPORTTIME=60

## }}}
## {{{ Options

setopt NO_beep          # Turn of the stupid beep

## }}}


