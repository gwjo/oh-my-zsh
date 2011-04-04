alias ctco='cleartool co -nc'
alias ctci='cleartool ci -cq'
alias ctact='cleartool lsact -cact -short'
alias ctpdiff='cleartool diff -g -pre'

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


function od() {
    ppcod -i $*
}

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


function mkact() {

    if [[ -z $1 ]] ; then
        echo "Bug number required"
        return
    fi

    local project=$(cleartool lsproject -cview -short 2> /dev/null)

    if [[ -z $project ]] ; then
        echo "Not in a view"
    else
        cleartool mkact gowen_${(L)project}_$1
    fi
}

function ctlocks() {
    local project=$(cleartool lsproject -cview -short 2> /dev/null)

    if [[ -z $project ]] ; then
        echo "Not in a view"
    else
        local opts="-short"
        if [[ $1 == "-l"  ]] ; then
            opts=""
        fi

        cleartool lslock $opts brtype:${project}_integration@/projects
    fi

}

