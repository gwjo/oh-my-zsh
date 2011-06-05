# Two line prompt, based heavily on Phil's prompt (http://aperiodic.net/phil/prompt/-)
# With some major updates from http://eseth.org/2010/git-in-zsh/#post-git-in-zsh
#



setopt prompt_subst
autoload colors
colors

autoload -U add-zsh-hook
autoload -Uz vcs_info

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git*:*' get-revision true
zstyle ':vcs_info:git*:*' check-for-changes true

# hash changes branch misc
zstyle ':vcs_info:git*' formats "(%s) %12.12i %c%u %b%m" # hash changes branch misc
zstyle ':vcs_info:git*' actionformats "(%s|%{$bg[white]%}%a%{$bg[gray]%}) %12.12i %c%u %b%m"



zstyle ':vcs_info:git*:*' stagedstr "%{$fg[green]%}S%{$fg_bold[black]%}"
zstyle ':vcs_info:git*:*' unstagedstr "%{$fg[red]%}U%{$fg_bold[black]%}"

# hooks to customize vcs output
zstyle ':vcs_info:git*+set-message:*' hooks git-st git-stash

add-zsh-hook precmd gwjo_theme_precmd_hook

gwjo_theme_precmd_hook() {
    vcs_info

    # Get the width of the terminal
    local i_term_width
    (( i_term_width = ${COLUMNS} - 1 ))

    # build the top line
    #  user[@host]:tty
    local -a infoline
    infoline+=( "%{$fg[green]%}%n" )                 # username
    [[ -n $SSH_CLIENT ]] && infoline+=( "@%m" );     # hostname if ssh
    infoline+=( ":%l" )

    # Strip color to find text width 
    local i_width
    i_width=${(S)infoline//\%\{*\%\}} # search-and-replace color escapes
    i_width=${#${(%)i_width}} # expand all escapes and count the chars

    local PR_FILLBAR=""
    local PR_PWDLEN=""

    # Truncate the pwd if it's too long
    local i_pwd_width=${#${(%):-%~}}  # password width
    if [[ "$i_width + $i_pwd_width" -gt $i_term_width ]]; then
        ((PR_PWDLEN=$i_term_width - $i_width))
        
    else
        PR_FILLBAR="%{$fg_bold[black]%}${(l:(($i_term_width - ($i_width + $i_pwd_width)))::.:)}"
        infoline+=( "${PR_FILLBAR}" )
    fi

    # now ready to add the current directory - yellow is read-only
    [[ -w $PWD ]] && infoline+=( "%{$fg[magenta]%}" ) || infoline+=( "%{$fg[yellow]%}" )
    infoline+=( " %$PR_PWDLEN<...<%~%<<" ) 

    ## Build the bottom line
    local -a bottom
    bottom+=( "%(1j.%{$fg_bold[black]%}[%j]%{$reset_color%} .)" ) # jobs
    bottom+=( "%(?..%{$fg[red]%}$?%{$fg_bold[black]%}:)%(!.%{$fg[red]%}.%{$fg[white]%})%#%{$reset_color%} " )

    
    ## now assemble the prompt
    local -a lines
    #  top line
    lines+=( ${(j::)infoline} )
    #  optional vcs line
    [[ -n ${vcs_info_msg_0_} ]] && lines+=( "%{$fg_bold[black]%}${vcs_info_msg_0_}%{$reset_color%}" )
    #  bottom line
    lines+=( ${(j::)bottom} )

    ## Finally set the prompt
    PROMPT=${(F)lines}

    # Right prompt
    #   time and date
    RPROMPT='  %{$fg_bold[black]%}%T %D{%a,%b%d}%{$reset_color%}'

    PS2='%{$fg_bold[black]%}%_%  > %{$reset_color%}'
}

# Show remote ref name and number of commits ahead-of or behind
function +vi-git-st() {
    local ahead behind remote
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        --symbolic-full-name --abbrev-ref 2>/dev/null)}

    if [[ -n ${remote} ]] ; then
        # for git prior to 1.7
        # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
        ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        (( $ahead )) && gitstatus+=( "%{$fg[green]%}+${ahead}%{$fg_bold[black]%}" )

        # for git prior to 1.7
        # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
        behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
        (( $behind )) && gitstatus+=( "%{$fg[red]%}-${behind}%{$fg_bold[black]%}" )

        hook_com[branch]="${hook_com[branch]} [${remote} ${(j:/:)gitstatus}]"
    fi
}

# Show count of stashed changes
function +vi-git-stash() {
    local -a stashes

    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        stashes=$(git stash list 2>/dev/null | wc -l)
        hook_com[misc]+=" (${stashes} stashed)"
    fi
}


#PROMPT='%{$fg[cyan]%}-%{$fg_bold[blue]%}-(%{$fg[green]%}%n@%m:%l%{$fg_bold[blue]%})-%{$fg[cyan]%}${(e)PR_FILLBAR}%{$fg_bold[blue]%}-(%{$fg[magenta]%}%$PR_PWDLEN<...<%~%<<%{$fg_bold[blue]%})-%{$fg[cyan]%}-
#-%{$fg_bold[blue]%}-(%(?..%{$fg[red]%}$?%{$fg_bold[blue]%}:)%{$fg[yellow]%}%T%{$fg_bold[blue]%}:%(!.%{$fg[red]%}.%{$fg[white]%})%#$(git_prompt_info)%{$fg_bold[blue]%})-%{$fg[cyan]%}- %{$reset_color%}'

#PS2='%{$fg[cyan]%}-%{$fg_bold[blue]%}-(%{$fg[green]%}%_%{$fg_bold[blue]%})-%{$fg[cyan]%}- %{$reset_color%}'

#RPROMPT='  %{$fg_bold[black]%}%D{%a,%b%d}%{$reset_color%}'


#  vim: set ft=zsh ts=4 sw=4 et:
