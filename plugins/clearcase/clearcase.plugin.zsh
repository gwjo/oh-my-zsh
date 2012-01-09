alias ctco='cleartool co -nc'
alias ctci='cleartool ci -cq'
alias ctact='cleartool lsact -cact -short'
alias cthijack='cleartool ls -visible | grep hijacked | cut -d "@" -f 1'

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

function ctpdiff() {
    if [[ $1 == "-h" ]] ; then
        local base
        base=$(cleartool ls $2 | grep hijacked | cut -d " " -f 1)

        cleartool diff -graphical $base $2
    else 
        cleartool diff -graphical -pre $1
    fi
}
