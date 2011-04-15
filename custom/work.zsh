## Some development related stuff

## {{{ autoload work functions

autoload sv
autoload _clearcase_getviews

## }}}
## {{{ update tags and cscopte



function uptags() {

    local ccviewtop=`ccbase`

    if [[ -z ${ccviewtop} ]] ; then
        echo "Not in a clearcase view!"
        return
    fi

    print -rC1 ${ccviewtop}/**/*.[ch](|pp) > ${ccviewtop}/cscope.files

    #/usr/bin/cscope -b -i $ccviewtop/cscope.files -f $ccviewtop/cscope.out
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
alias collect='app_cd collect'
alias h248='app_cd h248'
alias h323='app_cd h323'
alias lem='app_cd lem'
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
## {{{ Application launch aliases

alias wireshark='wireshark -a filesize:102400'

## }}}
## {{{ set CCBASE environment variable

function cc_set_ccbase() {
    local base=`/usr/local/acme/bin/ccbase`

    CC_BASE=""
    if [[ "x$base" != "x" ]] ; then
        if [[ -d $base/sd_iv ]] ; then
            CC_BASE=$base/sd_iv
        else
            CC_BASE=$base
        fi
    elif [[ "x$CC_BASE" = "x" ]] ; then
        echo "**********************************"
        echo "*** ERROR: No CC View selected ***"
        echo "**********************************"
        return 1
    fi
}

## }}}
## {{{ Pentium objdump

function od() {
    ppcod -i $*
}

## }}}
## {{{ Objdump (by default ppc)

function ppcod() {
    set +x
    local opt
    local objectfile
    local disOpt="d"
    local sourceOpt="CSl"
    local dumpCmd="objdumpppc"

    # loop continues till options finished
    while getopts ahiso: opt; do
        case $opt in
            (a)
                disOpt="D"
                ;;
            (i)
                dumpCmd="objdumppentium"
                ;;
            (o)
                objectfile="$OPTARG"
                ;;
            (s)
                sourceOpt=""
                ;;
            (h|\?)
                echo >&2 \
                "usage: $0 [-a] [-s] [-o objectfile] <start address> <end address>"
                return 1
                ;;
        esac
    done
    (( OPTIND > 1)) && shift $(( OPTIND - 1 ))


    if [[ -z ${2} ]]; then
        echo >&2 \
            "usage: $0 [-a] [-i] [-s] [-o objectfile] <start address> <end address>"
        return 1
    fi

    cc_set_ccbase
#    if [[ cc_set_ccbase() ]] ; then
#        return 1
#    fi

    local WIND_VERSION=`bash $CC_BASE/acme/lib/common/acmeVersion.sh -wind`

    # setup environment
    $WIND_VERSION

    if [[ -z $objectfile ]]; then
        objectfile="vxWorks";

        if [[ $WIND_VERSION == "vxe33a" ]]; then
            objectfile="vxKernel.sm"
        fi
    fi

    echo "$dumpCmd -${disOpt}${sourceOpt} --start-address=${1} --stop-address=${2} $objectfile"
    $dumpCmd -${disOpt}${sourceOpt} --start-address=${1} --stop-address=${2} $objectfile
}

## }}}

