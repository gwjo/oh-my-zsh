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


function ppcod() {
    local opt
    local objectfile
    
    # loop continues till options finished
    while getopts o: opt; do
        case $opt in
            (o)
                objectfile="$OPTARG"
                ;;
            \?)
                return 0
                ;;
        esac
    done
    (( OPTIND > 1)) && shift $(( OPTIND - 1 ))


    cc_set_ccbase()
#    if [[ cc_set_ccbase() ]] ; then
#        return 1
#    fi


    local WIND_VERSION=`bash $CC_BASE/acme/lib/common/acmeVersion.sh -wind`

    # setup environment
    $WIND_VERSION

    if [[ -z $objectfile ]]; then
        objectfile="vxWorks";
    fi


    echo "objdumpppc ... ${1} to ${2}"
    if [[ $WIND_VERSION == "vxe33a" ]]; then
        objdumpppc -C -d -l -S --start-address=${1} --stop-address=${2} vxKernel.sm
    else
        objdumpppc -C -d -l -S --start-address=${1} --stop-address=${2} $objectfile
    fi
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

