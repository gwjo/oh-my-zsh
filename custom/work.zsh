## Some development related stuff

## {{{ update tags and cscopte


function uptags() {

    local ccviewtop=`ccbase`

    if [[ -z ${ccviewtop} ]] ; then
        echo "Not in a clearcase view!"
        return
    fi

    print -rC1 ${ccviewtop}/**/*.[ch](|pp) > ${ccviewtop}/cscope.files

    /usr/bin/cscope -b -i $ccviewtop/cscope.files -f $ccviewtop/cscope.out
    /usr/bin/ctags -L $ccviewtop/cscope.files --extra=+q -o $ccviewtop/tags
}

## }}}

## {{{ change to directory based on SD stream
#
# Usage:
#
#  sd_cd <SD2 dir> <SD4 dir>
#
function sd_cd() {

    local cc_base=`/usr/local/acme/bin/ccbase`

    if [[ -z ${cc_base} ]] ; then
        echo "Not in a clearcase view"
        return
    fi

    if [[ -d ${cc_base}/$1 ]] ; then
        cd ${cc_base}/$1
    else
        cd ${cc_base}/$2
    fi
}

## }}}
## {{{ change to a acme directory

function acme_cd() {
    sd_cd acme/$1 sd_iv/acme/$2
}

## }}}
## {{{ change to an app directory
function app_cd() {
    acme_cd bin/$1 apps/$1
}

## }}}
## {{{ alias to move around the code base

alias base='sd_cd . .'
alias acme='acme_cd . .'
alias apps='app_cd .'
alias bin='app_cd .'
alias inc='acme_cd include/acme include'

alias acli='app_cd acli'
alias algd='app_cd algd'   # sd2 only
alias atcp='app_cd atcp'
alias h248='app_cd h248'
alias h323='app_cd h323'
alias mbcd='app_cd mbcd'
alias mgcp='app_cd algd'   # use this instead of algd (sd2 only)
alias sip='app_cd sip'

alias account='acme_cd lib/accounting lib/accounting'
alias common='acme_cd lib/common lib/common'
alias dam='acme_cd lib/dam lib/dam'
alias sig='acme_cd lib/sig lib/sig' # sd4 only

## }}}
## {{{ rebase and build an stream
#
# Usage:
#
#  rebase [make]
#  rebase <view> [make]
#
function rebase() {

    local do_make
    local cc_view
    local cc_base

    ## see if the first parameter is a view
    if [[ -n $1 && $1 != "make" ]] ; then
        cc_view=$1
        shift
    fi

    ## check for make option
    if [[ -n $1 && $1 == "make" ]] ; then
        do_make="true"
    fi

    # change to speficied view
    if [[ -n $cc_view ]] ; then
        sv $cc_view
    fi

    cc_base=$(/usr/local/acme/bin/ccbase)
    if [[ -z $cc_base ]] ; then
        echo "Not in a view"
        return
    fi

    /usr/local/acme/bin/ccrebase -latest
    /usr/local/acme/bin/ccrebase -complete

    if [[ -n $do_make ]] ; then
        sdmake
    fi
}

## }}}
