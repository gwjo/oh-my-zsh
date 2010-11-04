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
